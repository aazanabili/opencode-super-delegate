# Skill review and packaging notes

## Scope

Reviewed the existing skill against the complete compact and full Project Plan,
Clean Code and Security source texts, the user's hierarchy/cost requirements,
installed OpenCode CLI help (1.18.30), and official agent documentation.

## Corrected findings

| Finding | Resolution |
| --- | --- |
| Skill depended on repository-root policy files | Complete texts now travel inside the skill folder |
| Whole-book loading conflicted with token economy | Exhaustive indexes and clause coverage route exact applicable ranges to lower-tier roles |
| Planning used the strongest model by default | Premium L0 decides; cheaper L1 plans and delegates to progressively cheaper children |
| Hierarchy had no child edges or shared budget | Tier/edge controls, bounded depth/fan-out/invocations, lineage budgets and escalation |
| Planning agents could run before routing approval | Local metadata proposal first; all delegated work follows one interactive approval |
| Read-only helpers could use unrestricted terminal | Real read-only enforcement or denied shell; no parent permission escalation |
| Automatic correction implicitly granted edits | Explicit preapproved capability or diagnosis-only with authorized application |
| Correction could reuse the failed model | Different approved correction model and fresh session/delta handoff |
| Repair policy omitted revised-cycle ceiling | Three per cycle; one materially revised cycle, six per lineage, then escalation |
| Roles were named without an invocation adapter | Verified CLI forms, real agent registration, configuration/session/result handling |
| Flat shared result filenames caused collisions | Run/task/attempt-local records and serialized authoritative state |
| Security appeared only near completion | Risk review from sensitive requirements/design through final candidate |
| Initial planning was treated as final acceptance | Acceptance/requirements traceability rechecked on final candidate |
| Stale reviews could survive repair/integration | Candidate-bound evidence and invalidation rules |
| Premium model read too much context | Compact parent-mediated reports and targeted evidence retrieval |
| Sources and development conversation cluttered root | Sources relocated; historical conversation removed; README/install guidance added |
| MIT label had no accompanying license grant | Removed unsupported skill metadata; licensing remains an owner decision |

## Validation boundaries

Verified package results:

- Entry point: 88 lines; 23 Markdown files in the installable skill directory.
- Policy indexes: 24 Clean Code rows, 21 Project Plan rows, 44 Security rows;
  all nonblank source lines covered, including compact and full versions.
- Original text identity: all three pre-move Git blob hashes were reconstructed
  from the bundled texts by changing only terminal newline counts. No substantive
  source text was changed or omitted. Original identities:
  - Clean Code: `b6d57cccac8fb8c8a62d8b69b3955a03934aebac`
  - Project Plan: `79a518eb6c3319555ad4db2febc913fefa5b84af`
  - Security: `e8deceea5bcfe6e8a9caf5a97d3adcc3ee8562fd`
- Local Markdown links resolved and JSON example blocks parsed successfully.
- `git diff --check` passed for tracked changes.

Package checks cover frontmatter identity, local Markdown links, JSON examples,
policy index coverage, source preservation and whitespace/diff hygiene. Source
preservation is compared to pre-move Git blob identities, accounting for text
formatting normalization where necessary; it is not a claim of semantic review
of every future application of those policies.

Installed `opencode run --help` confirms model, agent, file, JSON event, session,
directory and variant options; `opencode models --help` confirms catalog and
verbose metadata options. Official agents documentation confirms model binding,
agent modes, task allowlists and last-match permission precedence.

No provider-backed multi-tier run, destructive permission test, cross-host install
or paid-model cost benchmark was performed as part of the static review. These
remain runtime acceptance checks, not passed tests. No commit, push or PR was made.

## Runtime acceptance checklist

In a disposable authorized project, approve real model IDs and a bounded budget:

1. Verify skill discovery and paths with the complete folder installed.
2. Verify first approval occurs before a delegated model call.
3. Run a cheaper planning lead with an allowed cheaper discovery child; record
   actual session/model identity, budgets and compact parent reports.
4. Confirm leaf delegation/write/CLI bypass attempts are denied by actual controls.
5. Run a tiny implementation plus independent review, then a controlled correction
   using a different approved model and no permission escalation.
6. Verify stale/wrong-candidate or malformed results cannot be accepted; test budget
   exhaustion, cancellation and resumption without duplicate external effects.
7. Confirm only L0 accepts the final candidate and publication respects approval.
8. Measure observed total cost/latency including coordination and rework before
   claiming savings against a defined baseline.
