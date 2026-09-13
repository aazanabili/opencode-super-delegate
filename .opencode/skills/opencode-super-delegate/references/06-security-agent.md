# Security Agent

Read `references/policies/Security.md` when detailed controls are needed; the
source is the repository's `Security.md`.

## Run Security Automatically When

The task affects authentication, authorization, identity, secrets, personal
or financial data, network boundaries, URLs or SSRF, SQL or deserialization,
files or archives, dependencies or package hooks, CI/CD or release
permissions, updates, migrations, persistence, IPC, native code, privilege,
cryptography, payments, production configuration, or broad shared
infrastructure. Also run it when the plan or diff reveals material threat
uncertainty.

For isolated prose, comments, or cosmetic changes with no executable,
configuration, dependency, permission, data, or trust-boundary effect, record
`NOT_APPLICABLE` and the specific reason instead of running the full gate.

## Review

Perform proportionate threat modeling, control review, secret and dependency
review, and negative/adversarial checks. Create read-only helpers for access
control, injection/file safety, supply chain, privacy/secrets, CI/platform,
and relevant runtime risks. Helpers report to `Security`; they do not approve
their own findings.

Return `PASS`, `FAIL`, or `BLOCKED`, with evidence, affected paths, residual
risk, and required remediation. A clean scanner result is not proof of
security; unavailable required checks are not `PASS`.
