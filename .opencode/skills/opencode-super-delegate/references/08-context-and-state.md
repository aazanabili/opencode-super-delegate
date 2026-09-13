# Context Compression and Durable State

Use independent sessions for `Project Plan`, implementation, `Clean Code`,
and `Security`. Reuse an implementation session for a correction only when the
runtime supports it and the session remains relevant.

Do not pass the full conversation or repository by default. Pass the complete
applicable policy packet, task contract, compact project summary, relevant
paths, changed files, known failures, and exact next actions.

Use compact artifacts such as:

```text
.orchestrator/plan.json
.orchestrator/task-result.json
.orchestrator/clean-code-report.json
.orchestrator/security-report.json
.orchestrator/correction-report.json
.orchestrator/handoffs/
```

Store large diffs and sanitized logs as referenced artifacts. Keep policy
packets separate from summaries so compaction cannot remove safety rules.
Reconcile saved state with actual files, revisions, processes, and external
operations before resuming.
