# Incremental test execution and final regression gate

Load when selecting or running checks. Testing is part of the active orchestration
loop; it does not imply a watcher or future scheduled run has been installed.

## After each coherent change

Identify affected behavior from the diff, callers, shared contracts and test map.
Run new/updated tests plus existing regressions for those behaviors and dependents
before accepting the increment. A coherent change is a compilable task increment,
not every keystroke or intermediate patch. Re-run checks invalidated by subsequent
code, fixture, dependency or configuration changes.

For shared libraries, schemas, dependency changes or uncertain impact, broaden
selection; do not claim a narrowly filtered suite rules out unrelated breakage.
Prefer the full relevant project regression suite at final integration when it
is feasible within approved resources. For large suites, use documented risk-based
selection and report unrun areas; mandatory release checks cannot be waived by cost.
Do not repeatedly execute unaffected expensive suites without new evidence need.

## Reliable execution

Verify runner discovery, expected nonzero test execution for functional tasks,
awaiting of asynchronous work, real assertions, exit status and target identity.
Capture exact commands/environment/candidate and sanitized logs. A zero exit code
with zero tests or skipped required tests is not PASS. Compilation alone does not
substitute for functional tests; mocked journeys do not prove real integration.

Run code only in the approved environment with bounded time, CPU/memory, concurrency
and service lifecycle. Tests may write fixtures/cache or start services; read-only
permissions are insufficient. Use owned temporary databases/ports/processes and
clean up only verified owned resources. Handle timeout/cancellation/child processes
under source Plan H–J; a killed wrapper does not prove its test server stopped.

## Failure and acceptance

Classify product, test, infrastructure, dependency, permission and flaky failures.
Record baseline failures explicitly. Do not rerun until green or silently ignore
new failures. A missing runtime/credential is BLOCKED/NOT_EVALUATED, not a test pass.
Use the bounded Correction loop for product defects and retest the original
failure plus neighboring behavior after correction.

At integration, inspect the combined diff and run the checks invalidated by
integration. Test reports and other gate reports must refer to the same candidate.
The Testing lead recommends acceptance only with persistent test files, accounted
core coverage and passing required checks; L0 alone decides final acceptance.
Application-wide no-regression claims require corresponding evidence and scope.
