# Implementation and Isolation

## Workspace

Every concurrent mutating task uses its own disposable Git worktree and task
branch, or an equivalent isolated checkout. Record the base revision and
workspace identity. If safe isolation is unavailable, serialize mutations in
one workspace and verify the baseline before and after each task.

Read-only reviewers may inspect an immutable candidate without another
worktree. Workers must not modify protected branches, other worktrees, shared
Git references, or unassigned paths.

## Execution

Implementation agents follow an approved task contract, run focused checks,
and leave evidence. They do not silently broaden scope. Shared files such as
lockfiles, CI configuration, public contracts, and migrations enter a
serialized integration queue.

An explicitly summoned agent may receive approved edit, terminal, Git, commit,
push, and PR permissions. Automatically created helper agents default to read,
search, and terminal use only.

Never resolve conflicts with blind `ours` or `theirs`. Never promote a worker
commit merely because it exists; validate the integrated candidate.
