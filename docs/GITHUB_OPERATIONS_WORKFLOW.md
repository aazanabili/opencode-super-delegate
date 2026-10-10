# GitHub Operations Workflow

Git and GitHub work follows the standard operational workflow in `AGENTS.md`,
with `git-agent` as the read-only advising specialist and Ephemeral Dynamic
Workers as the only executors.

```text
User
└── Primary Orchestrator
    ├── Read-only preflight
    │   ├── branch / HEAD / remotes / worktree
    │   ├── default branch and repository policy
    │   ├── existing PRs, Issues, releases, and workflows
    │   └── required permissions and approval classes
    ├── git-agent (Static Advisor, read-only)
    │   ├── branch naming and staging plan
    │   ├── atomic Conventional Commit messages
    │   ├── PR template and merge-conflict strategy
    │   └── exact Git steps for workers to execute
    ├── Approval gates (user-approved action classes)
    │   ├── local branch / commit
    │   ├── push / PR
    │   ├── merge / branch deletion
    │   ├── workflow dispatch / rerun
    │   ├── tag / release
    │   └── repository governance settings
    ├── Ephemeral Worker executes the bounded Git/GitHub task
    ├── verification-agent audits the final diff against requirements
    └── Status report (SUCCESS / FAILURE) returns to the Orchestrator
```

The default policy is GitHub Flow. External actions are never inferred from a
general implementation approval; the relevant action class must be approved.
Merge requires passing required checks, required reviews, no unresolved
conflicts, and explicit merge approval. Release versions are supplied manually.