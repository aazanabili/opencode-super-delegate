# Prompt integrity and context continuity

## Contract hierarchy

Every configured agent has an authoritative role contract in
`.opencode/opencode.jsonc`. The contract is loaded as the agent `system`
prompt.
A task brief, parent message, skill, or continuation may add bounded context,
but must never replace, summarize, truncate, weaken, or reinterpret the role
contract.

The effective order is:

1. Host and runtime safety controls.
2. The complete configured role prompt.
3. Approved skill instructions.
4. The scoped task brief and current evidence.
5. The agent's result/report contract.

If context is insufficient, the agent must report `CONTEXT_INSUFFICIENT`, name
the missing evidence, and request a focused continuation. It must not silently
omit requirements or pretend that a truncated prompt was complete.

## Continuity rules

- Parent agents send task briefs as additions, never as replacement prompts.
- Workers acknowledge `PROMPT_INTEGRITY_CONTRACT v1` in their structured report.
- Reports include the role ID, task ID, prompt contract status, files inspected,
  verification, blockers, and remaining work.
- Long source material is referenced by path and exact line/range instead of
  being copied repeatedly into every child context.
- A continuation uses the same role, workspace, policy packet, and task ID
  unless the manager explicitly records a new approved scope.
- Display truncation in a CLI/debug view is not treated as prompt truncation;
  validation must inspect the loaded configuration or the source file.

## Validation

Run the prompt-integrity validator before changing the agent fleet:

```text
node .opencode/skills/opencode-super-delegate/scripts/validate-prompt-integrity.mjs
```

The validator checks that all configured agents have non-empty `system`
contracts, the integrity contract, and the expected manager/lead/worker
population.
