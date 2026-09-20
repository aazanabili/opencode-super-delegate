---
name: opencode-super-delegate
description: Use when the user requests OpenCode Super Delegate or wants a premium model to retain final authority while cascading planning, execution, and review through progressively cheaper OpenCode models with compact upward reports.
compatibility: Requires an agent host with file and terminal tools, installed OpenCode CLI, Git for mutation tasks, and configured model access.
metadata:
  version: "1.3.0"
---

# OpenCode Super Delegate

Orchestrate through OpenCode; remain accountable for acceptance. This is a
portable instruction skill, not an installed fleet or autonomous daemon.
Resolve every reference relative to this SKILL.md directory, never the target
repository. Runtime artifacts belong to the target project, not this package.

## Core objective: premium decisions, inexpensive execution

The current highest-quality model is L0 and retains the final decision. Delegate
planning and routine coordination to cheaper L1 leads, bounded execution/review
to cheaper L2 specialists, and mechanical discovery to L3 helpers when useful.
L0 receives compact verified reports and issues decisions; it does not routinely
read source policies, implementation files, raw logs or child transcripts.
Load [hierarchy](references/14-cost-hierarchy.md) before routing. Minimize total
cost including rework and coordination, not just the price of one model call.

## Invariants

- Communicate in Arabic unless the user requests otherwise; preserve project
  language for code and technical documents.
- Ensure a delegated preflight inspects instructions, repository state and user edits before mutation.
  Preserve unrelated work. No destructive recovery or external actions without
  applicable authorization. Host/platform instructions take precedence.
- Discover models, propose justified routing and obtain one interactive approval
  before any delegated call. Never disable this checkpoint. YAML overrides
  automatic choices, not user authority. No silent model substitution.
- Explicitly summoned workers receive only the permissions approved for them.
  Automatic helpers are read-only, including their terminal operations. Parents
  cannot promote permissions. Read `references/12-permissions.md` before dispatch.
- Separate roles/sessions and keep context bounded. Branch per mutating task;
  sequential by default, isolated worktrees for concurrent mutation. A worktree
  is not a sandbox. Only the orchestrator accepts and integrates work.
- Maintain Project Plan, Testing, Clean Code and Security decisions for every candidate.
  Security may conclude NOT_APPLICABLE with evidence for low-risk work; this is
  not a claim that a full security review passed. Never accept unverified gates.
- Testing creates persistent executable tests in the target project for core and
  new functional behavior, updates tests for approved contract changes, and runs
  affected regressions after each coherent modification. Never rewrite expected
  results just to make a regression pass. Load its modules only when applicable.
- Preserve every applicable source requirement using the completeness protocol.
  Never infer success from a PASS keyword, worker prose, or file existence.

## Load on demand

Read the linked module at its trigger, not the entire reference directory.

| Trigger | Reference |
| --- | --- |
| Start / policy coverage | [Completeness](references/00-policy-completeness.md), [preflight](references/01-operating-contract.md) |
| Routing and approval | [Models](references/02-model-routing.md) |
| Hierarchical cost control | [Hierarchy](references/14-cost-hierarchy.md), [report filtering](references/15-report-escalation.md) |
| CLI invocation or role setup | [Runtime adapter](references/11-runtime-adapter.md), [permissions](references/12-permissions.md) |
| Planning / acceptance | [Project Plan](references/03-project-plan-agent.md) |
| Mutation / isolation | [Implementation](references/04-implementation-isolation.md) |
| Quality review | [Clean Code](references/05-clean-code-agent.md) |
| Test planning / functional change | [Testing](references/16-testing-agent.md) |
| Risk classification / sensitive work | [Security](references/06-security-agent.md) |
| Failed check | [Correction](references/07-correction-agent.md) |
| Handoff / continuation | [Context](references/08-context-and-state.md) |
| YAML supplied | [Overrides](references/09-yaml-overrides.md) |
| Task/result records | [Contracts](references/13-artifact-contracts.md) |
| Final integration / response | [Integration](references/10-integration-reporting.md) |
| Comprehensive feature discovery / web research / Git checkpoint | [Discovery and Git workflow](references/19-discovery-and-git-workflow.md) |

## Sequence

1. Inspect only enough local metadata to establish scope, capabilities and routing.
2. Discover and propose models, roles, permissions, budgets and Git actions;
   obtain interactive approval. Pre-approval planning is done by the current host.
3. Run a cheaper Project Plan lead as the first delegated role. It owns detailed
   preflight and planning through its approved cheaper children. Establish requirement IDs,
   policy coverage, dependencies and task contracts. Material changes outside
   approved bounds return for a focused decision; routine refinements do not.
4. Execute approved tasks. Begin applicable Security review at requirements and
   architecture, then revisit it as sensitive stages/diffs change.
5. Testing creates/maintains and executes tests after each coherent functional
   change, including affected existing regressions. Run independent Clean Code/
   Security review on the actual candidate and require the Testing gate.
   Failures use a different approved correction model and bounded repair cycle.
6. Project Plan verifies acceptance/traceability. A delegated integration operator
   prepares and verifies the combined candidate without accepting it. L0 reviews
   the compact gate/evidence reports, requests targeted clarification if necessary,
   and alone authorizes acceptance and approved publication.

For small tasks combine roles in the current host when appropriate and disclose
that no separate agents ran. Retain proportionate planning, quality review and
security/testing applicability decisions; do not invent application tests for prose.
