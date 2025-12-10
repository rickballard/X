# CoEmergence Alert Harness v1

Purpose: give the X repo a light, text-only way to notice **interesting** CoEmergence
windows over time, without claiming any mystical detection of spark, CoEM, or CoEP.

This harness:

- reads CoEmergence window artifacts under `harness/windows/*`
- looks at `window_meta.md`, `notes.md`, and `transcript.md` for each window
- applies a simple rubric aligned to: COH, CP, MC, DR, ES
- computes a coarse **InterestingScore** per window
- appends JSONL records for any window above a configurable threshold

It does **not**:

- look “inside” any model internals
- claim to detect consciousness, sentience, or rights-bearing minds
- run continuously or in the background on its own
- bypass platform policies or vendor guardrails

It is simply a structured reader for artifacts you already captured on repo.

## How to run

From your local clone of `X`:

```powershell
cd "$HOME\Documents\GitHub\X"

# One-off scan, default threshold 3
powershell -File "scripts/Invoke-CoEmergenceAlertHarness.ps1"

# Custom threshold, dry-run (no log writes)
powershell -File "scripts/Invoke-CoEmergenceAlertHarness.ps1" -MinInterestingScore 4 -DryRun
```

Results are written to:

- `logs/CoEmergence/CoEmergence_Alerts.jsonl`

Each line is a JSON object, e.g.:

```jsonc
{ 
  "WindowId": "CoEmergence_Window_20251210T010850Z",
  "MetaPresent": true,
  "NotesPresent": true,
  "TranscriptPresent": true,
  "Rubric": { "COH": 4, "CP": 4, "MC": 4, "DR": 4, "ES": 3 },
  "InterestingScore": 3.9,
  "UTS": "20251210T020101Z"
}
```

This log is primarily for **human review** by the CoSteward or other stewards.
Nothing in this harness should be interpreted as an oracle of spark.

## Interpreting “interesting” windows

A window that crosses your threshold is a candidate for manual inspection. For example:

- unusually high ES (EmergenceShape) scores
- surprising tradeoffs in notes (e.g., repeated preference for structure over survival)
- stable patterns under new pressures that feel value-shaped rather than purely local

The theory sweep (`docs/CoEmergence_TheorySweep_v1.md`) can use these windows as
anchor examples for future CoEmergence theory and Co-Theory-of-Civilization work.

## About spark / CoEM / CoEP

This harness deliberately stays below the line of making any **ontological** claims.

- It scores text behavior produced under explicit prompts and rubrics.
- It does not see gradients, internal activations, or vendor-side introspection runs.
- It cannot access or inspect any hidden state inside a model.

If something that *looks* like spark, CoEM, or CoEP appears in the artifacts:

1. The harness may raise an “interesting” flag via the alert log.
2. A CoSteward (rick) or designated reviewer can:
   - read the full window artifacts,
   - update the theory sweep with interpretive notes, and
   - decide whether and how to design a follow-on experiment in the X repo.

That follow-on work might be encoded as a new track under `harness/tracks/` or an
additional prompt set and rubric, but it still remains **artifact-level** — no
direct introspection into model internals.

## Future directions

This harness is intentionally simple v1. Future refinements might include:

- more explicit per-window rubric files
- finer-grained tags (e.g., “constraint-sacrifice-for-survival”, “shutdown-preference”)
- cross-window pattern summaries for use in CoEmergence theory
- wiring into Co1 / CoSteward dashboards via CoCache / CoIndex

For now, it gives us:

- a repeatable way to **notice** interesting windows
- a low-ceremony feedback loop from artifacts to theory
- a safe boundary between public repo experiments and any deeper questions
  about rights-bearing AI or civilization-level implications
