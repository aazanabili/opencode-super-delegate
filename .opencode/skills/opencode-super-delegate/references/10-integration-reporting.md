# Integration and Reporting

Run this module after gates pass.

L0 retains the acceptance decision. A cheaper integration operator can prepare
the candidate, inspect diffs and run checks under a bounded command contract.
Send a concise evidence packet to L0, not raw logs; no worker promotes itself.

1. Verify task ownership, base revision, policy version, risk, and evidence.
2. Build a candidate from the current accepted revision.
3. Apply changes through a serialized integration queue.
4. Resolve textual and semantic conflicts deliberately.
5. Run combined-candidate checks and inspect the final diff.
6. Perform only the approved Git actions: branch management, commit, push,
   merge, or pull request.

All gate reports must identify the same final candidate (commit or verified
snapshot including untracked/binary task files). Branch movement, repairs,
dependency changes and integration invalidate affected evidence. Reconcile and
revalidate before L0 acceptance. Publication of the accepted candidate is a
separate recorded operation; uncertain push/PR outcomes require reconciliation
before retry. Deployment/monitoring require their own scoped authority and proof.

Completion requires `Project Plan` pass, `Clean Code` pass, and applicable
`Testing` and `Security` passes. For application functionality, Testing requires
persistent tests covering core/new behavior and passing required regressions on
the final candidate. `NOT_APPLICABLE` must have a recorded reason; blocked or
unverified required checks are not approval.

Use exactly these five top-level Markdown bullets unless the user requests a
different format:

- **Changes:** Actual implementation/review scope and state.
- **Decisions:** Routing, isolation, architecture, and risk decisions.
- **Verification:** Actual commands, revisions, reports, and outcomes.
- **Limitations / Next steps:** Residual risks, blockers, and follow-up.
- **Runtime / Workspace:** Branch/worktree, processes, cleanup, commit, push,
  and pull-request results.

Report in Arabic, and never claim `PASS` or `complete` for unverified work.
