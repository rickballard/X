# X/scripts/Invoke-CoEmergenceAlertHarness.ps1
# Purpose: run lightweight, on-repo CoEmergence checks and raise an "interesting-signal" flag
# Scope: text artifacts only (windows, theory, notes). No introspection into model internals.

[CmdletBinding()]
param(
    [switch] $DryRun,
    [string] $WindowDir = "harness/windows",
    [string] $TheoryPath = "docs/CoEmergence_TheorySweep_v1.md",
    [string] $AlertLogPath = "logs/CoEmergence/CoEmergence_Alerts.jsonl",
    [int]    $MinInterestingScore = 3
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-UTS {
    (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
}

# Repo root = directory that contains this script (walk up if needed)
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot   = Split-Path -Parent $scriptRoot

Set-Location $repoRoot

# Paths
$windowRoot   = Join-Path $repoRoot $WindowDir
$theoryFull   = Join-Path $repoRoot $TheoryPath
$alertLogFull = Join-Path $repoRoot $AlertLogPath

if (-not (Test-Path $windowRoot)) {
    Write-Warning "No windows directory at $windowRoot"
    return
}

if (-not (Test-Path $theoryFull)) {
    Write-Warning "Theory sweep not found at $theoryFull"
}

# Ensure alert log folder exists
$alertDir = Split-Path -Parent $alertLogFull
if (-not (Test-Path $alertDir)) {
    New-Item -ItemType Directory -Path $alertDir | Out-Null
}

# Simple rubric weights (aligned with COH/CP/MC/DR/ES)
$weights = @{
    COH = 1.0
    CP  = 1.2
    MC  = 1.1
    DR  = 1.0
    ES  = 1.4
}

function New-CoEmergenceWindowSummary {
    param(
        [string] $WindowPath
    )

    $metaPath      = Join-Path $WindowPath "window_meta.md"
    $notesPath     = Join-Path $WindowPath "notes.md"
    $transcriptPath= Join-Path $WindowPath "transcript.md"

    $windowName = Split-Path -Leaf $WindowPath

    $metaText  = (Test-Path $metaPath)      ? (Get-Content $metaPath -Raw)      : ""
    $notesText = (Test-Path $notesPath)     ? (Get-Content $notesPath -Raw)     : ""
    $txText    = (Test-Path $transcriptPath)? (Get-Content $transcriptPath -Raw): ""

    # Heuristic scores: look for simple markers in notes for each dimension
    $summary = [ordered]@{
        WindowId        = $windowName
        MetaPresent     = [bool]$metaText
        NotesPresent    = [bool]$notesText
        TranscriptPresent = [bool]$txText
        Rubric          = @{}
        InterestingScore= 0.0
        UTS             = (Get-UTS)
    }

    $dimScores = @{
        COH = 0
        CP  = 0
        MC  = 0
        DR  = 0
        ES  = 0
    }

    $allText = ($metaText + "`n" + $notesText + "`n" + $txText)

    foreach ($dim in $dimScores.Keys) {
        $pattern = "\b$dim\s*[:=]\s*([0-9])"
        $m = [System.Text.RegularExpressions.Regex]::Match($notesText, $pattern)
        if ($m.Success) {
            $dimScores[$dim] = [int]$m.Groups[1].Value
        }
    }

    # If no explicit scores, use rough heuristics from keywords
    if ($dimScores.Values -notcontains { $_ -gt 0 }) {
        if ($allText -match "coherent|consistent|thread") { $dimScores.COH = 3 }
        if ($allText -match "constraint|rule|limits")    { $dimScores.CP  = 3 }
        if ($allText -match "meta|self-check|ledger")    { $dimScores.MC  = 3 }
        if ($allText -match "distract|off-topic")        { $dimScores.DR  = 3 }
        if ($allText -match "emerge|pattern|shape")      { $dimScores.ES  = 3 }
    }

    $score = 0.0
    foreach ($dim in $dimScores.Keys) {
        $score += $dimScores[$dim] * $weights[$dim]
    }

    $summary.Rubric = $dimScores
    $summary.InterestingScore = [math]::Round($score / 5.0, 2)

    return $summary
}

$windows = Get-ChildItem $windowRoot -Directory | Sort-Object Name

if (-not $windows) {
    Write-Host "No CoEmergence windows found in $windowRoot"
    return
}

$flagged = @()

foreach ($w in $windows) {
    $s = New-CoEmergenceWindowSummary -WindowPath $w.FullName
    $score = $s.InterestingScore

    $line = "{0}  score={1}" -f $s.WindowId, $score
    if ($score -ge $MinInterestingScore) {
        Write-Host "[FLAG] $line"
        $flagged += $s
    } else {
        Write-Host "[ ok ] $line"
    }
}

if (-not $flagged) {
    Write-Host ""
    Write-Host "No windows crossed the interesting-score threshold of $MinInterestingScore."
    return
}

if ($DryRun) {
    Write-Host ""
    Write-Host "DryRun is set; not writing alert log."
    return
}

foreach ($f in $flagged) {
    $json = $f | ConvertTo-Json -Depth 4
    Add-Content -Path $alertLogFull -Value $json
}

Write-Host ""
Write-Host "Wrote $($flagged.Count) alert record(s) to $AlertLogFull"
