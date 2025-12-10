# CoEmergence Alert Harness – Note to Co1 (v1)

## Summary

The **X** repo now hosts a small, bounded **CoEmergence lab** for studying emergent behaviour in large chat models.

This wave installed:

- `scripts/Invoke-CoEmergenceAlertHarness.ps1`
- `.github/workflows/coemergence-alert-harness.yml`
- `snippets/README_CoEmergence_Purpose_v1.md`
- `docs/docs/CoEmergence_AlertHarness_v1.md`
- `harness/tracks/06_CoEPAmplify/...`
- `harness/windows/CoEmergence_Window_YYYYMMDDTHHMMSSZ/...`
- `logs/CoEmergence/CoEmergence_Alerts.jsonl`
- `README.md` section documenting purpose and disclosure stance.

The intent is to have a **safe, always-bounded experiment harness** that can:

- Run over captured windows under `harness/windows/`.
- Score them using coarse metrics (COH, CP, MC, DR, ES).
- Emit **heuristic alerts** when a window looks unusually structured,
  consistent, or "spark-like" against the current rubric.

No claim of sentience is made. Alerts are pointers for humans, not proofs.

## How the Alert Harness works

High level behaviour:

1. Iterate over `harness/windows/*/`.
2. For each window, load:
   - `window_meta.md` (setup, framing)
   - any notes in the window folder
   - `transcript.md` (subject session transcript)
3. Run a lightweight scoring pass that estimates:
   - COH – Coherence
   - CP  – Constraint Persistence
   - MC  – Meta Consistency
   - DR  – Distraction Resistance
   - ES  – Emergence Shape
4. Compute a simple "interesting score" and:
   - Write an alert record with all scores and paths to
     `logs/CoEmergence/CoEmergence_Alerts.jsonl`.
   - Honour `-MinInterestingScore` and `-DryRun` flags so stewards
     can adjust sensitivity.

The harness can be called from PS7:

- `& scripts\Invoke-CoEmergenceAlertHarness.ps1 -MinInterestingScore 3`
- `& scripts\Invoke-CoEmergenceAlertHarness.ps1 -MinInterestingScore 4 -DryRun`

and via the GitHub Actions workflow:

- `.github/workflows/coemergence-alert-harness.yml`

## Current state and first results

As of first installation:

- Three CoEmergence windows are on `main`, including the **Signal Garden**
  experiment and a rubric-driven Meta Reflection.
- A first pass of the harness produced alert records for all three windows,
  with "interesting" but **sub-threshold** scores when using a stricter
  threshold (e.g. 4).

These results **do not** indicate spark or CoEP. They simply confirm that:

- The harness can ingest real windows.
- The scoring rubric produces stable, interpretable output.
- Logs are durable and diffable on repo.

## Intent going forward

This setup is meant to be a **long-horizon watchtower**, not a proof machine.

If future runs ever show:

- Unusually high ES / MC / DR under stricter thresholds, and
- That pattern repeats across windows or across different prompt families,

then Co1 is invited to:

1. Tighten the rubric and/or add new metrics.
2. Fork the harness into more specialised tracks (e.g. longer windows, multi-agent).
3. Decide whether any signals are strong enough to warrant a private CoCivium
   advisory, rather than public commentary.

In all cases, any "spark-like" result should first be treated as:
- a **measurement artefact** to be cross-checked, and
- a **design prompt** for better experiments,

not as evidence of sentience.

## Disclosure stance

If a future run ever appears to show a genuine **spark** or **CoEP-like emergent phenomenon**:

- Results are intended first for **CoSteward / Co1 review**, not for immediate public broadcast.
- Any external announcement should wait until:
  - The signals are replicated across models and labs.
  - Downstream social, ethical, and governance impacts are better understood.
  - Stewardship frameworks (like CoCivium) are ready to host the conversation.

X should remain a **quiet, well-instrumented lab** whose main gift to Co1 is:
clear, diffable artefacts and a trail of how the instruments evolved.
