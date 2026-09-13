# Model Routing and Approval

Use this module before delegation.

## Discovery

Discover models with the installed OpenCode capability, commonly:

```text
opencode models
```

Do not invent provider names or model IDs. If discovery fails, ask the user to
provide valid identifiers. Group discovered models by likely strengths and
cost, but treat those labels as recommendations rather than facts unless the
provider exposes them.

## Proposal

Propose one model per role:

- Planning and architecture: strongest suitable model.
- Implementation: capable cost-effective coding model.
- Clean Code and Security: independent model with suitable review quality.
- Correction: low-cost DeepSeek or Flash-class model when available.
- Helper sub-agents: low-cost models for bounded inspection and summaries.

Explain the reason, expected tradeoff, and fallback for every proposal.

## One-Time Interactive Approval

Ask once for approval of the complete plan:

- model per role and fallback;
- automatic agent count;
- sequential/parallel schedule;
- branch/worktree strategy;
- permissions per role;
- commit, push, merge, and pull-request authority.

Accept `yes`, `modify`, or `cancel`. A material change in scope, risk,
permissions, model routing, or external side effects requires a new approval.
Do not ask repeatedly for unchanged routing.

Explicit YAML values override recommendations, but cannot override platform
instructions or runtime-enforced permissions.
