# Context Compression and Durable State

Use independent sessions per role/model/workspace. Resume only a recorded session
with matching identity. A different correction model gets a fresh session and
delta handoff. Read source Plan D–F/M for exact state/resumption obligations.

Do not pass the full conversation or repository by default. Pass the complete
applicable policy packet, task contract, compact project summary, relevant
paths, changed files, known failures, and exact next actions.

Use compact artifacts such as:

```text
.orchestrator/plan.json
.orchestrator/runs/<run-id>/tasks/<task-id>/<attempt-id>/task-result.json
.orchestrator/runs/<run-id>/tasks/<task-id>/<attempt-id>/clean-code-report.json
.orchestrator/runs/<run-id>/tasks/<task-id>/<attempt-id>/security-report.json
.orchestrator/runs/<run-id>/tasks/<task-id>/<attempt-id>/correction-report.json
.orchestrator/handoffs/
```

Store large diffs and sanitized logs as referenced artifacts. Keep policy
packets separate from summaries so compaction cannot remove safety rules.
Reconcile saved state with actual files, revisions, processes, and external
operations before resuming.

Use [contracts](13-artifact-contracts.md) for validation, stale-write rejection
and ownership. Reports flow one tier upward; only summaries and evidence pointers
reach L0. Policy text is loaded by the responsible lower-tier lead/specialist,
not every ancestor. Maintain a separate current policy packet on every invocation.
