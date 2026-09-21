const endpoint = process.env.TYPESAFE_API_URL ?? "https://api.typesafe.ai/v1/systemone";
const apiKey = process.env.TYPESAFE_API_KEY;
const primaryModel = process.env.TYPESAFE_JEV_MODEL ?? "jev-latest";
const maxRetries = Number.parseInt(process.env.JEV_MAX_RETRIES ?? "2", 10);
const retryBaseMs = Number.parseInt(process.env.JEV_RETRY_BASE_MS ?? "400", 10);

if (!apiKey) {
  console.error("Missing TYPESAFE_API_KEY; Jev evaluation cannot run.");
  process.exit(2);
}

let input = "";
for await (const chunk of process.stdin) {
  input += chunk.toString();
}
let request;
try {
  request = JSON.parse(input);
} catch {
  console.error("stdin must contain a valid JSON System One request.");
  process.exit(2);
}

if (request.state === undefined || !request.questions || typeof request.questions !== "object") {
  console.error("Request requires state and a questions object.");
  process.exit(2);
}

const transientStatuses = new Set([408, 425, 429, 500, 502, 529]);
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function evaluate(model) {
  const payload = { ...request, model };
  let lastFailure;

  for (let attempt = 0; attempt <= maxRetries; attempt += 1) {
    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });
      const body = await response.text();

      if (response.ok) {
        return { ok: true, model, result: JSON.parse(body) };
      }

      lastFailure = { status: response.status, body };
      if (!transientStatuses.has(response.status) || attempt === maxRetries) break;
      const retryAfter = response.headers.get("retry-after");
      const retryAfterMs = retryAfter && Number.isFinite(Number(retryAfter))
        ? Number(retryAfter) * 1000
        : retryBaseMs * 2 ** attempt;
      await sleep(retryAfterMs);
      continue;
    } catch (error) {
      lastFailure = { error: error instanceof Error ? error.message : String(error) };
      if (attempt === maxRetries) break;
    }

    await sleep(retryBaseMs * 2 ** attempt);
  }

  return { ok: false, model, failure: lastFailure };
}

const attempt = await evaluate(primaryModel);
if (attempt.ok) {
  process.stdout.write(JSON.stringify({
    advisory_only: true,
    status: "completed",
    provider: "typesafe",
    model: attempt.result.model ?? primaryModel,
    answers: attempt.result.answers,
    usage: attempt.result.usage,
    attempts: [primaryModel],
  }, null, 2));
  process.exit(0);
}

process.stdout.write(JSON.stringify({
  advisory_only: true,
  status: "unavailable",
  provider: "typesafe",
  code: attempt.failure?.status === 429
    ? "RATE_LIMITED"
    : attempt.failure?.status === 529
      ? "TYPESAFE_OVERLOADED"
      : "JEV_REQUEST_FAILED",
  message: "Jev was unavailable; no advisory decision was produced.",
  endpoint,
  attempts: [{ model: primaryModel, failure: attempt.failure }],
  next_step: "Continue with deterministic lead planning and retry Jev later; do not treat this as PASS or FAIL.",
}, null, 2));
// Unavailability is a valid advisory outcome. Keep the process successful so
// the Manager can consume the structured result and continue deterministic work.
process.exit(0);
