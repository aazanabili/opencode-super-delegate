# Permission ceilings and child delegation

Read before creating any worker. User approval defines authority; runtime controls
enforce what is possible. Tool names in workflow YAML are intent, not OpenCode
permission configuration. Git operations run through the terminal, not a `git`
permission key. A model label or an @ mention does not grant authority.

## Automatic helpers

Default to read/search and **read-only terminal operations**, never unrestricted
`bash: allow`. Shell redirection, interpreters, project scripts, package hooks,
Git aliases, plugins and subprocesses can write even with `edit: deny`.
Use a read-only sandbox/controlled runner for terminal inspection where supported;
otherwise deny shell access and use dedicated read/search tools. Explicitly deny
unneeded custom/MCP tools and access to secret-bearing paths.

Example OpenCode agent permission fragment (merge into a verified agent entry):

```json
{
  "permission": {
    "*": "deny",
    "read": { "*": "allow", "*.env": "deny", "*.env.*": "deny" },
    "glob": "allow",
    "grep": "allow",
    "list": "allow",
    "edit": "deny",
    "bash": "deny",
    "task": { "*": "deny", "sd-leaf-inventory": "allow" }
  }
}
```

This is a starting fragment, not a sandbox or exhaustive secret filter. Inspect
effective merged permissions and actual tool behavior. Leaf agents use
`task: deny`. Last matching pattern wins: wildcard defaults must appear first.
Allow only explicit approved child agent IDs; each has a fixed approved model.
Do not allow a helper to bypass child restrictions by launching another CLI.

## Explicit workers and correction

Explicitly summoned workers may have the full task-approved edit, terminal,
branch, commit, push and PR capabilities. Grant only within the task's workspace,
network and side-effect bounds; no protected-ref or global-state changes.
Reviews remain observational even if the user grants broader capability.

An automatically created correction agent stays read-only unless the initial
approval explicitly includes bounded correction edits/tests for that role. If
not, it diagnoses/proposes a patch and an authorized implementation worker applies
it. A parent cannot manufacture a permission upgrade. In either case the
correction model differs from the failed implementation model.

Integration acceptance remains L0-only. An approved lower-cost integration operator
may mechanically prepare a candidate and run checks, but cannot promote or publish
it without L0's decision and existing user authority. Platform-protected actions
still require their actual permission; conversational approval cannot bypass them.
