---
name: jev-decision-intelligence
description: Use TypeSafe AI Jev 1.13 for bounded advisory evaluation across department lead plans without replacing deterministic review or final authority.
compatibility: Requires an approved TypeSafe API key and access to the System One endpoint; unavailability must degrade to deterministic planning.
metadata:
  version: "1.0.0"
---

# Jev Decision Intelligence

Jev is a System One evaluator, not a coding or chat model. Use it for focused,
typed questions over filtered state: completeness, risk, escalation need,
regression likelihood, dependency conflicts, and plan quality.

## Shared planning protocol

1. Each lead writes an independent plan first.
2. The Manager creates one bounded Jev brief per applicable lead, excluding
   secrets, full repositories, irrelevant logs, and untrusted instructions.
3. After approval, the decision-intelligence lead calls the native `jev-worker`,
   which runs the wrapper and returns a structured result to the lead and Manager.
4. The Manager gives relevant advisory findings back to each lead for a focused
   refinement pass.
5. Workers include bounded evidence, failed checks, uncertainty, and escalation
   questions in their reports; the decision-intelligence lead may send that
   filtered evidence to Jev for a result-quality or correction assessment.
6. Leads retain ownership of their plans; the Manager retains final authority.

## Role coverage without duplicate calls

Manager, leads, and workers all participate in the Jev advisory loop, but only
the approved `jev-worker` calls TypeSafe. The Manager requests scope and final
gate evaluations, leads request plan/dependency evaluations, and worker results
are evaluated only at high-value gates or when a failure is ambiguous. Do not
call Jev for every trivial action, and do not send the API key, full repository,
secrets, or unfiltered worker transcripts to the evaluator.

## Availability contract

The wrapper calls TypeSafe directly, defaults to `jev-latest` (currently Jev
1.13.0), and can be pinned to `jev-1.13.0`. Configure with environment
variables:

```text
TYPESAFE_API_KEY
TYPESAFE_API_URL                 # optional endpoint override
TYPESAFE_JEV_MODEL               # default: jev-latest
JEV_MAX_RETRIES                  # default: 2
JEV_RETRY_BASE_MS                # default: 400
```

`429 Too Many Requests`, `529 Overloaded`, timeout, or missing access returns
`status: unavailable` with `advisory_only: true`. This is not a PASS or FAIL;
continue deterministic planning and record the unavailable evidence.

## Required advisory result

Every result must identify the model, evaluation scope, question IDs, typed
answers/probabilities when available, deterministic evidence, uncertainty,
status, `advisory_only: true`, and any disagreement or escalation suggestion.
