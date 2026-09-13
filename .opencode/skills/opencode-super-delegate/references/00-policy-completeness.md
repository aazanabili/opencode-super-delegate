# Policy Completeness Rule

The repository-root files are the authoritative full texts:

- `Clean Code.md`
- `Project Plan.md`
- `Security.md`

The modular files in this directory reduce default context usage, but they do
not replace any source policy. They contain routing and orchestration rules.

## Loading Rule

1. Determine which gate or role is active.
2. Load the corresponding routing marker.
3. Load the entire canonical source file for that policy before deciding,
   reviewing, correcting, or approving.
4. Apply all applicable sections, not only sections named in the task.
5. Record sections that are not applicable and why; do not silently omit them.
6. If the source cannot be read completely, mark the affected gate
   `BLOCKED` or `NOT_EVALUATED`, never `PASS`.

## No Lossy Summaries

Summaries, compressed handoffs, helper reports, model memory, and token-saving
retrieval may carry pointers, decisions, evidence references, and exact next
actions. They must not replace the canonical policy while a policy gate is
active. Preserve the policy packet separately during compaction.

## Gate Mapping

- Planning, task graph, SDLC, workspaces, recovery, resources, or handover:
  read all of `Project Plan.md`.
- Code quality, tests, Git, architecture, debugging, implementation,
  performance, or final engineering report:
  read all of `Clean Code.md`.
- Security, privacy, dependencies, secrets, permissions, network, platform,
  release, recovery, or adversarial verification:
  read all of `Security.md`.
- If multiple gates apply, read every corresponding complete source file.

This rule is intentionally separate from task summaries so context compaction
cannot remove the obligation to consult the complete policies.
