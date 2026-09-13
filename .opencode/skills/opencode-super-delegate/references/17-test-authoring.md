# Persistent test authoring and maintenance

Load when Testing must create or change tests. Use the existing framework, runner,
package manager, test layout and naming conventions. If none exists, select the
smallest maintained stack-appropriate toolchain; validate exact commands/versions
and include needed dev-dependencies/configuration within approved scope.
Do not introduce a competing runner or framework-specific sample into every app.

## Coverage units

Create tests for observable functions/use cases, not copies of implementation.
Cover core business rules, normal paths, boundary/invalid inputs, meaningful errors
and recovery. Use unit tests for pure logic, integration/contract tests for actual
boundaries, and a small set of runnable end-to-end tests for critical user journeys.
Select concurrency, security, migration and platform tests when their guarantees
depend on real engines, independent connections, processes or release settings.

For each new capability, map its requirement and entry point to a test case.
Multiple cases/functions may share a cohesive test file; a literal file per function
is unnecessary. New apps must have at least one executed nontrivial test file and
coverage of their identified core behaviors, not only a rendering smoke test.
Existing core functions being modified need regression coverage before completion.

## Regression-safe updates

- Prefer a failing regression reproducer before a bug fix when practical; verify
  it detects the defect and passes on the corrected implementation.
- A refactor with unchanged contract should preserve assertions and expectations.
  Update legitimate imports/fixtures/API wiring without weakening semantics.
- An intentional behavior change needs a recorded new contract/acceptance criterion
  before updating expectations. Retain tests for unaffected compatibility/invariants.
- Investigate unexpected test failures first. Never rewrite tests to match broken
  output, blindly accept snapshots, delete failing cases, or add skips/retries to
  manufacture a passing result. Record justified removal of obsolete behavior.
- Keep test expectations independent: do not calculate expected values with the
  same production implementation or mock the guarantee under test.

## Reliability and repository integration

Use deterministic fixtures, controlled clocks/randomness, isolated data and cleanup.
No live credentials, production data, real charges, unapproved network calls or
shared database resets. Mock external boundaries appropriately; use authorized
sandboxes when real integration is required and report unavailable coverage.

Ensure the runner discovers and awaits the tests. Register a reproducible command
in existing scripts/configuration and document local setup in the application's
README. Use existing CI when present; propose new CI within project scope rather
than silently changing release permissions. Persist a proportionate behavior-to-test
map in existing test documentation or run evidence for later impact selection.

Tests, fixtures and required test configuration are application deliverables to
retain with source control under existing Git authorization. Temporary reports,
coverage output and caches follow project artifact/ignore rules.
