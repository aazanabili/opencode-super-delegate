# OpenCode Super Delegate

A portable skill for **cost-descending, hierarchical delegation through OpenCode**.
Keep your strongest, most expensive model as the decision owner. Cheaper models
handle planning, coordination, implementation and independent review; they can
delegate bounded work to still cheaper models. Compact evidence reports travel
upward, while final acceptance stays with the premium owner.

```text
L0 Premium owner — goals, commands, exceptions, final decision
  └─ L1 Cheaper leads — Project Plan, Testing, quality/security synthesis
       └─ L2 Cheaper specialists — implementation, focused review, correction
            └─ L3 Economical helpers — narrow discovery and inspection
```

Use fewer layers when delegation overhead exceeds the benefit. Cost and quality
depend on the chosen models, task and runtime; this package promises no fixed
savings percentage or universal correctness.

## What is included

- A small [SKILL.md](.opencode/skills/opencode-super-delegate/SKILL.md) entry point.
- On-demand references for routing, CLI execution, permissions, planning,
  isolation, review, recovery, structured results and compact reports.
- The complete original Project Plan, Clean Code and Security policies, including
  both compact and full versions, bundled with exhaustive section/range indexes.
- Mandatory one-time interactive approval of the routing tree, permissions,
  budgets and requested Git actions.
- Project Plan acceptance, Testing, Clean Code review and a Security decision tied to the
  same candidate. Sensitive work receives security review from design onward.

This is an **instruction package**, not an installed agent fleet, YAML executor,
process supervisor or permission sandbox. Its host uses actual OpenCode tools and
runtime controls. Installing the skill does not call models or publish code.

## Requirements

1. An agent host that can read skill files and invoke terminal commands. OpenCode,
   Codex and Claude Code can act as the premium owner; another host can follow the
   same entry point when it supports these capabilities.
2. An installed OpenCode CLI and configured provider authentication. Use the
   [official installation guide](https://opencode.ai/docs/) for your platform.
3. Git for task branches/worktrees and an isolated execution environment suitable
   for the target project. No Node/Python dependency is introduced by this skill.
4. Accessible, explicitly approved model IDs. A catalog listing alone does not
   prove access, current price, tool support or quota.

CLI examples were checked against **OpenCode 1.18.30**. Other versions must be
checked through installed help. Provider-backed execution is not certified by
static package validation.

## Installation

Download/extract this repository or clone it:

```text
git clone https://github.com/aazanabili/opencode-super-delegate.git
```

Copy the **entire** `.opencode/skills/opencode-super-delegate` directory, including
`references/`. Copying only `SKILL.md` breaks policy and workflow retrieval.

### OpenCode: project-local

Place the directory in the project you want to work on:

```text
YOUR_PROJECT/.opencode/skills/opencode-super-delegate/
  SKILL.md
  references/
```

This repository already uses that layout, so OpenCode can discover the skill
when opened here. No `opencode.json` change is required for the standard path.

### OpenCode: global

Place the same directory at:

```text
~/.config/opencode/skills/opencode-super-delegate/
```

On Windows the default home expansion is
`%USERPROFILE%\.config\opencode\skills\opencode-super-delegate\`.
Respect a customized configuration directory if your installation uses one.

Example PowerShell, run from this downloaded repository, for a fresh global copy:

```powershell
$source = Join-Path (Get-Location) '.opencode\skills\opencode-super-delegate'
$parent = Join-Path $HOME '.config\opencode\skills'
$destination = Join-Path $parent 'opencode-super-delegate'
if (-not (Test-Path -LiteralPath (Join-Path $source 'SKILL.md'))) { throw 'Run from the downloaded repository.' }
if (Test-Path -LiteralPath $destination) { throw 'Existing installation: review and back it up before updating.' }
New-Item -ItemType Directory -Path $parent -Force | Out-Null
Copy-Item -LiteralPath $source -Destination $destination -Recurse
```

Quit and **restart OpenCode** after installation or updates. Existing sessions
retain their loaded configuration. Avoid multiple stale installations with the
same skill name; inspect the loaded path if discovery appears inconsistent.

### Codex, Claude Code and other hosts

The workflow is host-independent; OpenCode remains the delegated CLI. Put the
complete skill folder in the host's supported skill directory, or explicitly
ask the host to read the installed `SKILL.md` by absolute path. For Claude Code,
the conventional project skill path is `.claude/skills/opencode-super-delegate/`.
For Codex/shared agent installations, consult the current host's skill discovery
configuration (commonly `.agents/skills/`); do not assume one host registers
another host's agents automatically. The explicit-file method also works when
automatic discovery is unavailable.

## Usage

Start with a natural-language request:

> Use OpenCode Super Delegate. Keep the current premium model as the final
> decision owner. Delegate planning and execution through progressively cheaper
> models. Implement this feature, run independent reviews, and return concise
> reports. Propose the hierarchy and permissions for my approval first.

Arabic example:

> استخدم OpenCode Super Delegate. أبقِ النموذج الحالي صاحب القرار النهائي، ووزّع
> التخطيط والتنفيذ والمراجعة هرميًا على نماذج أقل تكلفة. اقترح النماذج والصلاحيات
> والميزانية أولًا، ثم نفّذ بعد موافقتي وأرسل تقارير مختصرة فقط.

The owner discovers models, proposes the cheaper tiers and permitted child edges,
then asks for approval once. The cheaper Project Plan lead performs detailed
preflight and decomposition. Children stay within the approved tree and shared
budgets. New out-of-scope authority requires a focused decision; routine work
within the approved bounds does not repeat the approval flow.

Optional [workflow YAML](.opencode/skills/opencode-super-delegate/references/09-yaml-overrides.md)
can specify exact role models and ceilings. It is input to the skill, not a native
OpenCode configuration file. Replace all placeholder model IDs before use.

## Permissions, quality and cost

### Automatic persistent testing

The **Testing** role creates real test files in each target application using its
existing stack and test conventions. Core and new functional behavior receives
executable coverage. Tests persist with the app for future changes; a JSON report
alone is not coverage, and there is no generic framework forced on every project.

After each coherent functional change, Testing runs new/updated tests and affected
existing regressions. Final integration runs the relevant regression suite, with
broader checks for shared changes or uncertain impact. Missing required checks
block acceptance. Tests are updated for approved behavior changes or demonstrated
test defects, never simply to make broken output pass.

This role uses cheaper leads/specialists, approved test-path writes and bounded
execution. Clean Code independently checks test integrity; the premium owner
receives a compact result and retains acceptance authority. No always-running
watcher is installed; execution occurs as part of the skill workflow.

Read [Testing](.opencode/skills/opencode-super-delegate/references/16-testing-agent.md),
[test authoring](.opencode/skills/opencode-super-delegate/references/17-test-authoring.md)
and [regression execution](.opencode/skills/opencode-super-delegate/references/18-test-execution.md).

### Execution controls

- Automatic helpers have read/search and only genuinely read-only terminal use;
  unrestricted shell access would defeat `edit: deny`.
- Explicit workers can receive approved edit/test/Git capabilities. Automatically
  created correction roles cannot promote their own permissions.
- Configured child allowlists, depth/fan-out/call ceilings and persistent repair
  budgets prevent unbounded recursion. Default mutation concurrency is one.
- Reports are reconciled by the immediate parent. L0 receives decisions, evidence
  pointers and blockers instead of source dumps. It may request targeted evidence.
- The lower-tier integration operator prepares/tests a candidate; only L0 accepts
  it. Commit/push/PR actions need task authorization; installation grants none.
- Prices and savings are labeled as observed, estimated or unknown. The cheapest
  incapable model is not economical when repeated failure outweighs savings.

## Policy preservation and retrieval

The three original texts are in
[`references/policies/`](.opencode/skills/opencode-super-delegate/references/policies/).
Indexes cover their entire compact and full versions. A responsible lower-tier
lead reviews all section applicability, retrieves exact applicable ranges, and
records clause-level evidence/exclusions. Policies are not replaced with lossy
summaries, and the premium owner need not load all policy books.

The original Markdown wrappers and duplicate compact/full presentations are
retained for provenance. No dependency on root-level source files remains.
See [policy completeness](.opencode/skills/opencode-super-delegate/references/00-policy-completeness.md).

## Repository layout

```text
README.md
docs/
  REVIEW.md
.gitattributes
.gitignore
.opencode/skills/opencode-super-delegate/
  SKILL.md
  references/
    00-policy-completeness.md … 18-test-execution.md
    policies/
      Clean Code.md          # complete retrieval index
      Project Plan.md        # complete retrieval index
      Security.md            # complete retrieval index
      clean-code-source.md   # original compact + full text
      project-plan-source.md
      security-source.md
```

Runtime evidence belongs to the target project's coordination directory, not
this skill folder. The development conversation is excluded from the package.

## Updating, uninstalling and troubleshooting

- Update from a reviewed revision. Back up local customizations, replace the
  whole skill directory deliberately, and restart the host. Revalidate indexes
  if a policy source changes; line ranges are version-bound.
- Uninstall by removing only the skill directory you installed. Task branches,
  project changes and evidence are independent and should be retained as needed.
- If the skill is missing, verify the exact directory/frontmatter name, host
  discovery path and permission to load skills, then restart.
- If dispatch fails, inspect installed CLI help, real agent registration, model
  access and effective permissions. Do not fix it by enabling blanket permissions.
- JSON CLI events are not final task results. Missing reports or unrun required
  checks remain unresolved, even if an agent prints `PASS`.

## Validation and publication status

See [review notes](docs/REVIEW.md) for checked behavior and remaining runtime
verification. The source policy's warning against unsupported perfect-security
claims also applies to this package. No license has been selected by the owner;
the earlier unsupported MIT label has been removed. Choose an appropriate license
before advertising an open-source license grant.
opencode-super-delegate
