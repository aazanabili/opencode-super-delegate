# Integration and Reporting

Run this module after gates pass.

1. Verify task ownership, base revision, policy version, risk, and evidence.
2. Build a candidate from the current accepted revision.
3. Apply changes through a serialized integration queue.
4. Resolve textual and semantic conflicts deliberately.
5. Run combined-candidate checks and inspect the final diff.
6. Perform only the approved Git actions: branch management, commit, push,
   merge, or pull request.

Completion requires `Project Plan` pass, `Clean Code` pass, and applicable
`Security` pass. `NOT_APPLICABLE` must have a recorded reason; blocked or
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
