import fs from "node:fs/promises";

const endpoint = process.env.OPENCODE_ZEN_SYSTEMONE_URL ?? "https://opencode.ai/zen/v1/systemone";
const apiKey = process.env.OPENCODE_API_KEY;

if (!apiKey) {
  console.error("Missing OPENCODE_API_KEY; Jev evaluation cannot run.");
  process.exit(2);
}

const input = await fs.readFile(0, "utf8");
let request;
try {
  request = JSON.parse(input);
} catch {
  console.error("stdin must contain a valid JSON System One request.");
  process.exit(2);
}

request.model = "jev-1.13";
if (request.state === undefined || !request.questions || typeof request.questions !== "object") {
  console.error("Request requires state and a questions object.");
  process.exit(2);
}

const response = await fetch(endpoint, {
  method: "POST",
  headers: {
    Authorization: `Bearer ${apiKey}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify(request),
});

const body = await response.text();
if (!response.ok) {
  console.error(`Jev request failed (${response.status}): ${body}`);
  process.exit(1);
}

const result = JSON.parse(body);
process.stdout.write(JSON.stringify({
  advisory_only: true,
  model: result.model,
  answers: result.answers,
  usage: result.usage,
}, null, 2));
