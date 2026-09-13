# Correction Agent

Create a general `Correction Agent` automatically when `Clean Code` or
`Security` reports a failure. Prefer a low-cost DeepSeek or Flash-class model
from the approved model list.

Pass only the relevant report, task contract, changed paths, known failures,
and required checks. Do not pass the entire conversation or repository by
default.

The correction agent may edit and test only its assigned branch/worktree. It
must not weaken assertions, remove security controls, change acceptance
criteria, or hide failures. After correction, rerun the failing gate and
affected tests.

Use at most three repair attempts per cycle, preserving the counter across
reassignment and context compaction. After exhaustion, stop mutation,
quarantine evidence, and escalate a diagnostic report. Do not loop by merely
rewording the same request.
