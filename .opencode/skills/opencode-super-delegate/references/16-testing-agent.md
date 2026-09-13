# Testing agent — persistent functional regression coverage

Testing is a first-class gate alongside Project Plan, Clean Code and Security.
Map it to source Plan A9/phase 5; consult Plan L, Clean Code 19 and relevant
Security J controls through the complete policy indexes. It is a logical role
instantiated using [the runtime adapter](11-runtime-adapter.md), not a daemon
installed by loading this Markdown file.

## Responsibility and cost hierarchy

Use a capable cheaper L1 Testing lead. It may delegate bounded test authoring,
execution and investigation to approved cheaper L2 specialists; L3 helpers can
inventory tests/callers. All use the shared budgets and permission ceilings.
Return compact evidence through the immediate parent; L0 retains final acceptance.
Reserve testing capacity during the initial routing approval, not after spending
the entire budget on implementation. Merge roles for small tasks when economical.

## When to activate

- Every new application, web app, service, library or executable feature must
  contain real, persistent test files for its core functional behavior before
  completion. A test plan/report or an empty scaffold is not a test suite.
- Every new functional capability gets executable coverage of its contract.
  Existing tests may cover a refactoring/helper through its public behavior;
  do not create one ceremonial file per private helper/getter.
- For existing applications, inspect core workflows and current coverage. Add
  tests for changed/new core behavior and affected untested dependencies. Record
  unrelated legacy gaps rather than silently claiming whole-application coverage
  or performing an unauthorized full rewrite of its tests.
- After each coherent modification, run affected tests before accepting that
  increment. After integration, run combined-candidate regression checks.
- Pure prose/nonfunctional changes may record NOT_APPLICABLE with rationale.
  Configurations, migrations, agent instructions and build changes need impact
  assessment; a Markdown extension does not imply they are non-executable.

## Workflow

1. During planning, inventory the stack, runner, scripts, tests, fixtures, core
   functions/user journeys, callers, acceptance criteria and available environments.
   Establish a baseline separating pre-existing failures from regressions.
2. Read [test authoring](17-test-authoring.md). Define independent expected
   behavior, then create/update actual tests in the target project's conventions.
   Test files persist with the application; never put them in the installed skill.
3. Read [execution and regression](18-test-execution.md). Run focused tests after
   modifications and the required broader checks before final acceptance.
4. Classify failures with evidence. Product defects go through Correction;
   demonstrated test defects/approved contract changes receive justified updates.
   Clean Code independently reviews test integrity and any reduced coverage.
5. Return a Testing report for the exact tested candidate: PASS, FAIL, BLOCKED,
   NOT_EVALUATED or justified NOT_APPLICABLE. Required unrun tests block acceptance.

## Authority

The initial approved role contract must include writes to assigned test/fixture
paths and bounded test execution, which may run code and create temporary files.
Testing may propose runner/config/dev-dependency changes; an authorized worker
applies shared-file changes through the serialized integration process. Never
grant itself broader shell, dependency-install or product-edit authority.
Automatic read-only helpers only inspect/propose; an authorized test writer applies
their proposals. Do not let test author and implementer race over shared files.

## Evidence contract

Write `testing-report.json` in the run/task/attempt directory under
[artifact contracts](13-artifact-contracts.md). Include:

- Requirement/function/behavior IDs mapped to persistent test paths and test names.
- Added/updated test paths; reason and approved contract reference for updates.
- Exact command, runner/environment, candidate identity, exit status and log refs.
- Discovered/executed/passed/failed/skipped counts when exposed (otherwise unknown).
- Baseline comparison, regressions, untested core gaps and justified exclusions.
- Selected focused/integration/full-suite scope, dependency-impact rationale,
  blockers, residual risks and next action.

Clean Code checks test quality; Testing owns executable regression evidence;
Security determines threat-specific checks. Share valid evidence across roles
instead of rerunning unchanged checks. Passing selected tests proves only their
assessed behavior, not that every possible application behavior is correct.
