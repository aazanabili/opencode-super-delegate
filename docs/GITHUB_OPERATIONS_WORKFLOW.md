# GitHub Operations Workflow

```text
Manager
└── github-operations-lead
    ├── Read-only preflight
    │   ├── branch / HEAD / remotes / worktree
    │   ├── default branch and repository policy
    │   ├── existing PRs, Issues, releases, and workflows
    │   └── required permissions and approval classes
    ├── Route to one skill
    │   ├── git-workflow
    │   ├── github-pr
    │   ├── github-issues
    │   ├── github-release
    │   ├── github-actions
    │   └── github-governance
    ├── Approval gates
    │   ├── local branch / commit
    │   ├── push / PR
    │   ├── merge / branch deletion
    │   ├── workflow dispatch / rerun
    │   ├── tag / release
    │   └── repository governance settings
    ├── Execute bounded worker task
    ├── Verify actual result and external ID/URL
    └── Return evidence report to Manager
```

The default policy is GitHub Flow. External actions are never inferred from a
general implementation approval; the relevant action class must be approved.
Merge requires passing required checks, required reviews, no unresolved
conflicts, and explicit merge approval. Release versions are supplied manually.
