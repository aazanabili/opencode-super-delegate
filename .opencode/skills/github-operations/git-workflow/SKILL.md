---
name: git-workflow
description: Safely manage local Git branches, worktrees, commits, rebases, and conflicts under GitHub Flow.
---

# Git Workflow

Use GitHub Flow unless the repository documents a different policy. Inspect
status, HEAD, branch, remotes, and user changes first. Create a short-lived
branch from the intended base, never overwrite unrelated changes, and stop on
unexpected state. Commit messages must describe the approved change. Rebase,
merge, branch deletion, and force-push require explicit approval; force-push is
denied by default. Report exact branch, commit, and verification evidence.
