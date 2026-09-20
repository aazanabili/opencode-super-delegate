# OpenCode CLI adapter

Read only when setting up or dispatching roles. This skill defines logical roles;
merely naming Project Plan does not register an OpenCode agent. Do not invoke a
nonexistent agent or assume the host Task API accepts per-call models.

## Capability check

Use trusted installed help: `opencode --version`, `opencode run --help`,
`opencode models --help`, and `opencode debug agents`. Reference the V2
documentation for [CLI](https://opencode.ai/v2/docs/cli),
[agents](https://opencode.ai/v2/docs/agents), and
[configuration](https://opencode.ai/v2/docs/config). Recheck flags on the
installed version.

## Two supported dispatch strategies

1. **Native configured agents:** approved role/model pairs are registered in
    project-local agent configuration with ordered `permissions` and explicit
    `subagent` allowed-child edges.
   Use native Task only if the installed runtime supports the required caller,
   child/session and model controls. Do not assume a subagent can spawn children.
2. **CLI role sessions:** use a verified primary/all agent with its model and
   permissions configured for the role; attach its bounded brief. A coordinator
   can return child requests for the dispatching controller to validate and run.
   This preserves the logical hierarchy without claiming unsupported nested Task.

If required controls are unavailable, stop the affected dispatch and report the
limitation; sequential role simulation must be labeled, never reported as a fleet.

## Invocation pattern

Replace every placeholder with an approved verified value. Run in the assigned
worktree using the host tool's working-directory argument. File paths must be
absolute or resolved relative to that worktree, not the skill directory.

```text
opencode run "Execute the attached task contract; return its structured result." --agent APPROVED_AGENT --model PROVIDER/MODEL --format json --file ABSOLUTE_BRIEF_PATH
```

`--format json` emits events, not a schema-valid task result by itself. Capture
exit status, error events, session ID, final message and artifacts; validate the
result under [contracts](13-artifact-contracts.md). Reject missing/partial results.

Continue only the recorded session for the same role/worktree/policy:

```text
opencode run "Apply the attached follow-up contract." --session EXACT_SESSION_ID --agent APPROVED_AGENT --model PROVIDER/MODEL --format json --file ABSOLUTE_DELTA_PATH
```

Do not use global `--continue` in a multi-role fleet. A correction on a different
model starts a fresh role session with a delta handoff; implementation sessions
may resume for ordinary follow-ups. Record actual model identity rather than
assuming inheritance. Do not use nonexistent `--resume-last` or `--read-only` flags.

## Configuration and lifecycle

Use an existing compliant agent or, within approval, create a task-scoped
`OPENCODE_CONFIG` JSON for the new child process. Validate fields against the
official schema; use distinct `sd-*` names and inspect merged configuration.
Never overwrite user global config. `OPENCODE_CONFIG_CONTENT` is another supported
child-scoped override; avoid leaking it into unrelated launches and restore any
parent environment value. Do not put credentials in the config, brief or logs.

Agent entries use `description`, `mode`, `model`, `system`, `permissions` and
optionally finite `steps`. CLI-selectable roles use `mode: all` or `primary`;
task-only children use `subagent`. Permission rules are ordered V2 rules with
`action`, `resource` and `effect`; the last matching rule wins. Inject the full
approved policy packet and role brief, with skill-root paths, not the full skill
orchestration loop.

Use actual host background/process tools if available; record process/session
handles, bounded polling and command deadlines. A foreground terminal call is
not a background service. On timeout inspect owned descendants before retry.
Never infer termination from a lost heartbeat. Refer to source Plan H–J/M for
quarantine/fencing and recovery. If unattended permission asks cannot be handled,
return BLOCKED rather than enabling blanket auto-approval. The inspected CLI has
`--auto`; this skill does not require or recommend it as permission enforcement.

Preserve UTF-8 Arabic prompts/results and actual shell quoting. Attach prompt
files instead of shell-interpolating repository/user text. Verify non-ASCII
round trips in the host when needed; PowerShell 5.1 and newer shells differ.
New configuration takes effect in new processes; restart an existing OpenCode
session after installing or changing this skill or agent configuration.
