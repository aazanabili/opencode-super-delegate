# Clean Code — complete retrieval index

Source: [clean-code-source.md](clean-code-source.md). Read inclusive line ranges
from this file using bounded reads. Follow [coverage](../00-policy-completeness.md).
For each applicable row, retrieve both columns; no detail is replaced by this index.

| Section | Compact lines | Full lines |
| --- | --- | --- |
| Introduction | 1–5 | 184–194 |
| 0 Operating contract | 6–8 | 195–204 |
| 1 Context / acceptance | 9–11 | 205–215 |
| 2 Git / concurrent work | 12–18 | 216–232 |
| 3 Filesystem / execution | 19–27 | 233–249 |
| 4 Services / processes | 28–34 | 250–268 |
| 5 Scope / edits | 35–41 | 269–282 |
| 6 Debugging | 42–48 | 283–298 |
| 7 Bounded execution | 49–57 | 299–317 |
| 8 Architecture | 58–62 | 318–331 |
| 9 Reuse / DRY | 63–67 | 332–346 |
| 10 Functions | 68–74 | 347–362 |
| 11 Types / state | 75–81 | 363–383 |
| 12 Errors / cleanup | 82–88 | 384–399 |
| 13 Async / concurrency | 89–95 | 400–418 |
| 14 Security baseline | 96–104 | 419–442 |
| 15 Persistence / integration | 105–111 | 443–457 |
| 16 Migration / recovery | 112–120 | 458–478 |
| 17 UI / clients | 121–125 | 479–493 |
| 18 Performance | 126–130 | 494–508 |
| 19 Verification | 131–139 | 509–532 |
| 20 Dependencies / configuration | 140–146 | 533–552 |
| 21 Refactoring / docs | 147–153 | 553–572 |
| 22 Handoff / completion / output | 154–183 | 573–630 |

Always consider introduction, 0–5, 7, 14, 19–22 for engineering work; classify
the remaining sections from actual behavior. This is a starting set, not an
exemption list. Conditional requirements within selected sections still require
applicability decisions rather than automatic irrelevant work.
