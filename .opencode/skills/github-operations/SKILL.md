---
name: github-operations
description: Manage Git and GitHub workflows with explicit approval gates for branches, pull requests, GitHub Actions, releases, issues, and repository governance.
compatibility: Requires Git, GitHub CLI or an approved GitHub integration, and explicit authorization for external side effects.
metadata:
  version: "1.0.0"
---

# GitHub Operations

Use this skill for GitHub-only repository operations. The default development
model is GitHub Flow: create a short-lived branch from the repository default
branch, make and verify changes, push, open a pull request, wait for required
checks/reviews, and merge only after explicit approval.

## Operating contract

1. Run a read-only preflight before mutation: current branch, HEAD, remotes,
   worktree state, default branch, existing PRs, and relevant workflows.
2. Preserve unrelated user changes. Stop on an unexpected branch, remote,
   conflict, missing anchor, or uncertain external-operation result.
3. Ask for approval immediately before each external side-effect class:
   push/PR, merge/delete branch, tag/release, workflow dispatch/rerun, and
   repository governance changes.
4. Never print, copy, or persist tokens, secrets, environment values, or private
   logs that are not required for the task.
5. Do not force-push, bypass protections, merge failing checks, or create
   duplicate PRs/releases by default.
6. Return evidence: command/result, branch or commit, PR/run/release number and
   URL where applicable. Do not claim completion from intent or a CLI request.

## Routing

- `git-workflow`: local branches, worktrees, commits, rebase and conflicts.
- `github-pr`: pull request preparation, creation, review and merge readiness.
- `github-issues`: issues, labels, milestones and project coordination.
- `github-release`: manual SemVer/tag/release preparation and verification.
- `github-actions`: workflow inspection, validation, runs and failures.
- `github-governance`: CODEOWNERS, templates, rulesets and approved settings.

The `github-operations-lead` coordinates these skills and returns a compact
report to the Manager. It does not replace the Manager's final authority.

## Required report format

- **Changes:** requested and actual Git/GitHub operations.
- **Decisions:** approvals, policy assumptions, and risk decisions.
- **Verification:** commands, checks, IDs, URLs, and outcomes.
- **Limitations / Next steps:** blockers or remaining approvals.
- **Runtime / Workspace:** branch, worktree, commit, push, PR, merge, and
  release state.
