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
- A first-class `github-operations-lead` with GitHub Flow, PR, Issues, release,
  GitHub Actions, and scoped repository-governance skills. External GitHub side
  effects remain approval-gated.

This is an **instruction package**, not an installed agent fleet, YAML executor,
process supervisor or permission sandbox. Its host uses actual OpenCode tools and
runtime controls. Installing the skill does not call models or publish code.

## Requirements

1. An agent host that can read skill files and invoke terminal commands. OpenCode,
   Codex and Claude Code can act as the premium owner; another host can follow the
   same entry point when it supports these capabilities.
2. An installed OpenCode CLI and configured provider authentication. Use the
   [official installation guide](https://opencode.ai/v2/docs/) for your platform.
3. Git for task branches/worktrees and an isolated execution environment suitable
   for the target project. No Node/Python dependency is introduced by this skill.
4. Accessible, explicitly approved model IDs. A catalog listing alone does not
   prove access, current price, tool support or quota.

CLI examples and the agent configuration are aligned with the **OpenCode V2
configuration format**. Recheck command flags through installed help because
runtime versions can differ. Provider-backed execution is not certified by
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

## TypeSafe Jev advisory layer

Jev is used as a bounded, advisory evaluator through the TypeSafe System One
endpoint. It does not write code, replace deterministic tests, or own the final
decision. The practical flow is:

```text
Manager: scope, risk and routing evaluation
  ↓
Leads: detailed plans and task decomposition
  ↓ Jev evaluates plan completeness, dependencies and risk
Workers: bounded implementation, tests and evidence
  ↓ Jev evaluates selected results, failures and escalation need
Lead: reconciliation and correction tasks
  ↓
Manager: final acceptance
```

All levels use Jev evidence, but they do not all call the provider directly.
The approved `jev-worker` is the only component that runs the wrapper. This
prevents duplicate calls and keeps the API key out of ordinary worker prompts.
Jev is called at high-value gates: scope, lead plan, ambiguous or failed worker
results, and final acceptance. For trivial tasks, deterministic execution can
continue without a Jev call.

If TypeSafe is unavailable, the result is recorded as advisory `unavailable`
and deterministic planning, testing and review continue. It is never treated
as PASS or FAIL.

### TypeSafe environment variables

Never put credentials in `opencode.jsonc`, `SKILL.md`, prompts, source files or
Git. Configure these variables in the shell or secret manager that starts
OpenCode:

```text
TYPESAFE_API_KEY=your-rotated-key
TYPESAFE_API_URL=https://api.typesafe.ai/v1/systemone
TYPESAFE_JEV_MODEL=jev-latest
JEV_MAX_RETRIES=2
JEV_RETRY_BASE_MS=400
```

On Windows PowerShell, for the current terminal only:

```powershell
$env:TYPESAFE_API_KEY = "YOUR_NEW_KEY"
$env:TYPESAFE_JEV_MODEL = "jev-latest"
opencode
```

For future terminals, use `setx` with a newly rotated key, then restart
OpenCode. Do not paste the key into chat or commit it. For CI, create a secret
named `TYPESAFE_API_KEY` and expose it only to the job that runs the evaluator.

## Installing on a new machine

### 1. Install prerequisites

Install Git, OpenCode V2, and authenticate the providers whose models you plan
to use. Verify the runtime before installing the fleet:

```powershell
opencode --version
git --version
opencode debug config
```

### 2. Clone and install the global OpenCode configuration

```powershell
git clone https://github.com/aazanabili/opencode-super-delegate.git
Set-Location opencode-super-delegate

$global = Join-Path $HOME '.config\opencode'
$backup = Join-Path $global ('opencode.jsonc.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $global -Force | Out-Null
if (Test-Path (Join-Path $global 'opencode.jsonc')) {
  Copy-Item (Join-Path $global 'opencode.jsonc') $backup
}
Copy-Item '.opencode\opencode.jsonc' (Join-Path $global 'opencode.jsonc') -Force

$skills = Join-Path $global 'skills'
New-Item -ItemType Directory -Path $skills -Force | Out-Null
Copy-Item '.opencode\skills\opencode-super-delegate' (Join-Path $skills 'opencode-super-delegate') -Recurse -Force
Copy-Item '.opencode\skills\github-operations' (Join-Path $skills 'github-operations') -Recurse -Force
Copy-Item '.opencode\skills\jev-decision-intelligence' (Join-Path $skills 'jev-decision-intelligence') -Recurse -Force
```

Restart OpenCode after changing global configuration. Global configuration is
loaded from `%USERPROFILE%\.config\opencode\opencode.jsonc`; a project's
`.opencode/opencode.jsonc` has higher precedence and may override it.

### 3. Select a model for each agent

Every agent has its own `model` field in `opencode.jsonc`:

```jsonc
{
  "agents": {
    "manager": { "model": "openai/gpt-6-luna" },
    "project-plan-lead": { "model": "openai/gpt-6-luna" },
    "pp-worker-1": { "model": "openai/gpt-6-luna" },
    "jev-worker": { "model": "openai/gpt-6-luna" }
  }
}
```

The native delegation tree requires a depth of `2` for the approved
`Manager → Lead → Worker` path. Do not increase it unless a deeper tree is
explicitly reviewed, because depth increases fan-out and token consumption:

```jsonc
{
  "experimental": {
    "subagent_depth": 2,
  },
}
```

Use a model ID that is actually available to your provider. The recommended
tier pattern is:

| Agent group | Role | Typical model tier |
|---|---|---|
| `manager` | final routing and acceptance | strongest available |
| `*-lead` | analysis, decomposition and review | cheaper capable model |
| `*-worker` | bounded implementation and tests | economical model |
| `jev-worker` | TypeSafe wrapper execution only | economical tool-capable model |

The model configured for `jev-worker` is the OpenCode model that prepares and
returns the TypeSafe request; the Jev model itself is selected independently by
`TYPESAFE_JEV_MODEL`.

List accessible models with:

```powershell
opencode models
```

After changing an agent model, run:

```powershell
opencode debug config
node .opencode\skills\opencode-super-delegate\scripts\validate-prompt-integrity.mjs
```

Optional [workflow YAML](.opencode/skills/opencode-super-delegate/references/09-yaml-overrides.md)
can specify exact role models and ceilings. It is input to the skill, not a native
OpenCode configuration file. Replace all placeholder model IDs before use.

#### Bulk model change script (`tmp/Set-OCModels.ps1`)

`tmp/Set-OCModels.ps1` rewrites the `model` field of every managed agent in
`opencode.jsonc` — the single `manager`, the 7 leads (`project-plan-lead`,
`clean-code-lead`, `testing-lead`, `security-lead`, `seo-lead`,
`decision-intelligence-lead`, `github-operations-lead`) and the 35 workers
(the `pp-worker-*`, `cc-worker[-]?`, `test-worker-*`, `sec-worker-*`,
`seo-worker-*`, `github-*-worker` and `jev-worker` agents).

Two files can be targeted, depending on `-Scope`:

- **Project file** — the nearest `.opencode\opencode.jsonc` to your
  **current working directory**, found by walking upward.
- **Global file** — `%USERPROFILE%\.config\opencode\opencode.jsonc`.

##### Prerequisites

- **PowerShell 5.1 minimum** (the script declares `#requires -Version 5.1`).
  Windows PowerShell 5.1 ships with Windows 10/11; PowerShell 7 (`pwsh`)
  also works.
- The **global file must already exist and be readable**, even when you
  only plan to update the project file: presets initialize their default
  values from the current global models at startup. Run `opencode debug
  config` at least once before the first run if it is missing.
- Run the script **from inside the target project directory**, because
  `-Scope all` and `-Scope project` both walk upward from the current
  working directory to locate the project file. The script's own location
  does not determine the project root.

##### Invocation

```powershell
# Windows PowerShell 5.1
powershell -File .\tmp\Set-OCModels.ps1 ...

# PowerShell 7 (recommended)
pwsh .\tmp\Set-OCModels.ps1 ...
```

Every example below uses `pwsh`; substitution with `powershell -File
.\tmp\Set-OCModels.ps1` is equivalent on Windows PowerShell 5.1.

##### Parameters

| Parameter | Accepted values | Default | Effect |
|---|---|---|---|
| `-Scope` | `all` \| `project` \| `global` | `all` | Which `opencode.jsonc` file(s) to edit |
| `-Preset` | `default` \| `workers-m3` \| `all-m3` \| `all-gpt5` | `default` | Pre-fills target values; see presets below |
| `-Manager` | any model ID (string) | current global `manager` | New model for `manager` |
| `-Leads` | any model ID (string) | current global lead | New model for every lead |
| `-Workers` | any model ID (string) | current global worker | New model for every worker |
| `-Yes` | switch | off | Skip the final `Apply? [Y/n]` confirmation |
| `-Interactive` | switch | off | Use the interactive picker (writes immediately, see below) |

Any group parameter (`-Manager`/`-Leads`/`-Workers`) **overrides** the
value supplied by `-Preset` for that group only. Agent groups not
mentioned are left untouched (no cross-group replacement, no
deletion-style fill). PowerShell parameter names are case-insensitive
but the canonical spellings above are recommended.

With no group parameter and `-Preset default`, the script prints
"Nothing to do." and exits without writing anything (so `pwsh
.\tmp\Set-OCModels.ps1 -Scope project -Yes` is a no-op).

##### Preset → target mapping

| Preset | Manager | Leads | Workers |
|---|---|---|---|
| `default` | current global `manager` model | current global lead model | current global worker model |
| `workers-m3` | unchanged | unchanged | `minimax-coding-plan/MiniMax-M3#thinking` |
| `all-m3` | `minimax-coding-plan/MiniMax-M3#thinking` | `minimax-coding-plan/MiniMax-M3#thinking` | `minimax-coding-plan/MiniMax-M3#thinking` |
| `all-gpt5` | current global `manager` model | current global lead model | current global worker model |

`all-gpt5` re-applies whichever three model IDs the global file currently
holds (for example the `*-sol` / `*-terra` / `*-luna` family if that is
your setup). Pair a group parameter with a preset to override just that
group; the other groups still follow the preset.

##### Scope matrix

| `-Scope` | Project file required | Global file required | Files updated |
|---|---|---|---|
| `all` | yes (walked up from CWD) | yes (must exist and be readable) | project + global |
| `project` | yes | **yes** (read at startup for preset seeding) | project only |
| `global` | no | yes | global only |

A missing or unreadable project file under `-Scope all` / `-Scope project`
fails fast; a missing or unreadable global file fails fast under every
scope.

##### Representative commands

Every preset:

```powershell
# workers-m3: workers on M3, manager + leads untouched (both files)
pwsh .\tmp\Set-OCModels.ps1 -Preset workers-m3

# all-m3: all three groups on M3, global file only
pwsh .\tmp\Set-OCModels.ps1 -Preset all-m3 -Scope global

# all-gpt5: re-apply whatever models the global file currently has, both files
pwsh .\tmp\Set-OCModels.ps1 -Preset all-gpt5 -Scope all -Yes

# default: no-op (prints the "Nothing to do." banner)
pwsh .\tmp\Set-OCModels.ps1
```

Every group parameter on its own:

```powershell
# Update only the manager in both files
pwsh .\tmp\Set-OCModels.ps1 -Manager 'openai/gpt-5.6-sol'

# Update only the leads in the project file
pwsh .\tmp\Set-OCModels.ps1 -Leads 'openai/gpt-5.6-terra' -Scope project

# Update only the workers in the global file (no confirmation prompt)
pwsh .\tmp\Set-OCModels.ps1 -Workers 'openai/gpt-5-mini' -Scope global -Yes
```

Combined group parameters (any subset is allowed):

```powershell
pwsh .\tmp\Set-OCModels.ps1 `
  -Manager 'openai/gpt-5.6-sol' `
  -Leads   'openai/gpt-5.6-terra' `
  -Workers 'minimax-coding-plan/MiniMax-M3#thinking' `
  -Scope   all
```

Combining a preset with one group override — preset drives two groups,
the parameter overrides the third:

```powershell
pwsh .\tmp\Set-OCModels.ps1 -Preset workers-m3 -Manager 'openai/gpt-5.6-sol'
```

Interactive picker:

```powershell
pwsh .\tmp\Set-OCModels.ps1 -Interactive
```

##### Interactive picker (`-Interactive`)

```powershell
pwsh .\tmp\Set-OCModels.ps1 -Interactive
```

The picker offers a four-step nested menu — group → agents within the
group → provider → model — and **writes each change immediately** to
the files in scope. It does **not** print a preview, does **not** ask
`Apply? [Y/n]`, and `-Yes` has no effect here.

- The group menu exposes only `manager` (1 agent), `leads` (7 agents)
  and `workers` (35 agents); press `q` to quit. A per-agent picker is
  not surfaced even though helper functions for it exist in the script.
- Within a group, press Enter (or type `all`) to apply to every agent,
  or pick by index: `1,3,5` or `9-12`.
- The provider list prefers `~/.config\opencode\cache\models-catalog.json`
  and falls back to parsing the textual output of `opencode models`.
- If the chosen model carries a `#variant` (for example `#thinking`) and
  the base id matches the current sample, the picker prompts `Keep
  current variant '#thinking' on the new model? [Y/n]`.
- Press `q` at any picker prompt to quit (as documented for the group menu).

##### Safety, backups and rollback

For every file the script edits it:

1. Copies the original to `<file>.backup-yyyyMMdd-HHmmss` (local time).
2. Replaces only the matching `"model": "<old>"` value, preserving the
   rest of the line, indentation and `//` comments.
3. Validates the rewritten file as JSON (after stripping `//` comments);
   if parsing fails, **restores the backup** and aborts that file.

The project and global files are processed **sequentially, one at a
time**. The script does **not** promise cross-file atomicity: a failure
on the second file is not rolled back to the first. In the explicit-CLI
batch path a JSON error halts the rest of the batch; in interactive mode
a JSON error logs a `Restored backup.` line and moves on to the next
file. Inspect any leftover `opencode.jsonc.backup-*` files and archive
or delete them once the new configuration is verified.

##### Restart OpenCode

The script ends with `Done. Restart OpenCode to pick up the new models.`
Existing OpenCode sessions keep their already-loaded configuration;
only freshly started sessions honour the updated `model` fields.

```powershell
# quit any running opencode session, then:
opencode
opencode debug config
```

Verify the active configuration with `opencode debug config` or
`opencode models` before resuming normal work.

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
  GITHUB_OPERATIONS_WORKFLOW.md
.gitattributes
.gitignore
.opencode/
  opencode.jsonc            # V2 agents, permissions, command and plugins
  package.json              # local OpenCode plugin dependency
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
.opencode/skills/github-operations/
  SKILL.md
  git-workflow/ … github-governance/
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
