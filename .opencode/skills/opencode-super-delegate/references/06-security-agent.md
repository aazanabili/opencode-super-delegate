# Security Agent

Use a cheaper qualified independent Security lead and approved cheaper focused
specialists. Read [the index](policies/Security.md), classify all sections and
retrieve complete applicable ranges under [coverage](00-policy-completeness.md).

## Run Security Automatically When

The task affects authentication, authorization, identity, secrets, personal
or financial data, network boundaries, URLs or SSRF, SQL or deserialization,
files or archives, dependencies or package hooks, CI/CD or release
permissions, updates, migrations, persistence, IPC, native code, privilege,
cryptography, payments, production configuration, or broad shared
infrastructure. Also run it when the plan or diff reveals material threat
uncertainty.

Review sensitive requirements/architecture before implementation, relevant
development/release stages, and the final actual diff. Always reassess risk after
changes. Agent instructions and permission configuration are execution controls,
not automatically low-risk prose. Source Plan L defines tiers 0–4 and source
Security A/I/J applies across relevant security work.

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

Record a clause-level Control Evidence Matrix per Security J5: control ID,
applicability/rationale, enforcement point, implementation evidence, verification
evidence, status, residual risk and owner. Preserve J7's seven output dimensions
in the detailed security report; summarize them into the five-bullet final report
without losing material information. L0 receives the compact decision packet.
