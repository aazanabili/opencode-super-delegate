# Durable task and result contracts

Read source Plan E and Security J5 where applicable. Use project conventions or
`.orchestrator/runs/<run-id>/tasks/<task-id>/<attempt-id>/`. Never share one mutable
task-result file among concurrent workers. Paths are task data, never commands;
validate containment, ownership and symlink/reparse behavior before writes.

## Required records

| Record | Required fields |
| --- | --- |
| Run / plan | schema_version, run_id, revision, policy_version, approved_scope, authorization, routing, allowed_edges, budgets, accepted_revision, requirements, tasks, phase_gates, decisions, UTC timestamp |
| Task contract | task_id, parent_id, lineage_id, attempt_id, version, objective, requirement_ids, owner, reviewer, tier, model, allowed_children, dependency_versions, base_revision, workspace, owned_paths, deliverables, risk/rationale, checks/exclusions, resource_request, timeout, retry_counters, escalation_conditions, policy_packet |
| Task result | identity fields, policy_version, state_revision, status, actual_model, session_id, base_revision, candidate_id, dependency_versions, changed_paths, artifacts, checks, coverage, findings, counters, resource_refs, decisions, blockers, next_actions, UTC timestamp |
| Gate / review | task/candidate/policy identity, gate, reviewer/model, status, findings with severity/path/line/control/evidence/remediation, checks, coverage/exclusions, residual_risks, recommended_decision |
| Coverage | source/version, section/clause, applicability/rationale, enforcement_point, implementation_evidence, verification_evidence, status, owner, residual_risk |
| Testing report | gate/review identity fields, behavior_test_map, added/updated test paths, contract-change reasons, baseline comparison, check counts when known, selected regression scope/rationale, untested gaps, blockers and next action |

Each check records exact command or inspection method, target/environment,
tested candidate, actual outcome, exit code if executed, and sanitized evidence
reference. Unknown fields such as monetary cost/session IDs are null with a reason,
not invented. Record token/cost observations separately from estimates.

Task states: PENDING, READY, RUNNING, IN_REVIEW, DONE, BLOCKED, FAILED, CANCELLED.
Only L0 authorizes DONE. Gate statuses: PASS, FAIL, BLOCKED, NOT_EVALUATED,
NOT_APPLICABLE. Check statuses may additionally be NOT_RUN/SKIPPED with reasons.
An applicable required gate cannot pass with an unmet/unverified required check.
Security NOT_APPLICABLE is allowed only with a recorded risk-based rationale.
Testing NOT_APPLICABLE requires no applicable functional test obligation; it cannot
excuse a new application/feature with no executable tests. Test files live in the
target application's normal test layout; `testing-report.json` is evidence, not a
substitute. Refer to [Testing](16-testing-agent.md) for the complete report fields.

## Validation and publishing

Before accepting a record, validate object shape, required fields/types/enums,
unique IDs, finite nonnegative counters, dependency/candidate identity, permission
and budget bounds, evidence existence and tested revision. Extra extension fields
need a versioned contract; unknown schema versions are blocked. Use the host's
available structured validation; these Markdown contracts are not a claim that
a schema validator or atomic store has been installed.

Workers propose task-local state; a single authorized controller serializes
global records, compares expected state revisions and atomically replaces files
or uses a supported transaction. If atomic operations cannot be enforced, serialize
and record that limitation; do not claim concurrency safety. Stable message and
operation IDs prevent duplicate dispatch and repeated external side effects.

Reject malformed JSON, partial event streams, missing reports, wrong revisions,
unresolved error events and prose that merely contains PASS. On interruption keep
the task unresolved and reconcile actual process/artifact/external state first.
