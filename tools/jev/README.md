# Jev Evaluator (TypeSafe System One) — Advisory Only

`jev-evaluate.mjs` wraps `POST https://api.typesafe.ai/v1/systemone` (TypeSafe AI "System One" decision model Jev). It is an ADVISORY evaluator for the multi-agent architecture (AGENTS.md): it returns typed decisions with calibrated probabilities and NEVER owns the final decision.

## Contract
- Invoke: `node tools/jev/jev-evaluate.mjs < request.json` — reads all of stdin as JSON, prints one JSON result to stdout. Exit 0 on completed AND unavailable; exit 2 on invalid input.
- Input: `{ "state": string|object|array, "questions": { "<id>": { "type": "noul"|"choice"|"score", "instructions": "...", "criteria": ... } } }`
- Output (success): `{ advisory_only: true, status: "completed", provider: "typesafe", model, answers, usage, attempts }`
- Output (failure): `{ advisory_only: true, status: "unavailable", provider: "typesafe", code, message, endpoint, attempts, next_step }` — `unavailable` is NOT a pass or fail; continue deterministic work.

## Configuration (environment)
- `TYPESAFE_API_KEY` (required; from the TypeSafe console — never commit/print it)
- `TYPESAFE_API_URL` (optional endpoint override; default `https://api.typesafe.ai/v1/systemone`)
- `TYPESAFE_JEV_MODEL` (optional; default `jev-1.13.0` — pinned per user decision, previously `jev-latest`)
- `JEV_MAX_RETRIES` (default 2), `JEV_RETRY_BASE_MS` (default 400; exponential backoff, honors numeric retry-after in seconds)

## Usage gates (AGENTS.md architecture)
Only the Primary Orchestrator decides when to evaluate; it runs the wrapper through an Ephemeral Worker (orchestrator and advisors hold no shell). High-value gates: scope/risk evaluation, advisor-plan review, ambiguous or failed worker results, final acceptance. Trivial tasks may skip evaluation.

## Hard rules
- Send only task-relevant redacted state. Never send the API key, secrets, full repository dumps, or unfiltered transcripts.
- Record the response `model` (the resolved version that answered) and `usage` in reports.
- Jev is advisory evidence only; acceptance authority stays with the orchestrator and the user.

## Regression Testing
The wrapper's original `0xC0000409` crash reproduced only on the **live network path** (real DNS + TLS + undici keep-alive). Localhost mocks returned exit 0 even on the buggy build, so a localhost-only regression test would have falsely reported a fix. **Always exercise the regression check against the real TypeSafe endpoint (or a stub that keeps a TLS handle open)** — otherwise the test does not actually cover the failure mode.