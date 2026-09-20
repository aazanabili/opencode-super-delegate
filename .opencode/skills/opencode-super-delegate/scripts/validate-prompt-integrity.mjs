import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const configPath = path.join(root, ".opencode", "opencode.jsonc");
const source = fs.readFileSync(configPath, "utf8").replace(/^\s*\/\/.*$/gm, "");
const config = JSON.parse(source.replace(/^\uFEFF/, ""));
const agents = config.agents ?? {};
const entries = Object.entries(agents);
const requiredMarker = "PROMPT INTEGRITY CONTRACT v1";
const missing = entries.filter(([, agent]) =>
  typeof agent.system !== "string" ||
  !agent.system.trim() ||
  !agent.system.includes(requiredMarker),
);

const expectedGroups = [
  ["manager", 1],
  ["project-plan-lead", 1],
  ["clean-code-lead", 1],
  ["testing-lead", 1],
  ["security-lead", 1],
  ["seo-lead", 1],
  ["decision-intelligence-lead", 1],
  ["pp-worker-", 6],
  ["cc-worker-", 6],
  ["test-worker-", 6],
  ["sec-worker-", 6],
  ["seo-worker-", 6],
];

const populationErrors = [];
for (const [prefix, expected] of expectedGroups) {
  const actual = prefix.endsWith("-")
    ? entries.filter(([id]) => id.startsWith(prefix)).length
    : entries.filter(([id]) => id === prefix).length;
  if (actual !== expected) populationErrors.push(`${prefix}: expected ${expected}, found ${actual}`);
}

if (missing.length || populationErrors.length) {
  if (missing.length) console.error(`Missing or incomplete system contract: ${missing.map(([id]) => id).join(", ")}`);
  for (const error of populationErrors) console.error(error);
  process.exit(1);
}

console.log(`System contract integrity OK: ${entries.length} agents validated.`);
