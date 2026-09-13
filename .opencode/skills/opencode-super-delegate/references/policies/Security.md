# Security — complete retrieval index

Source: [security-source.md](security-source.md). Inclusive 1-based ranges;
retrieve both versions for each applicable row under the
[coverage protocol](../00-policy-completeness.md).

| Section | Compact lines | Full lines |
| --- | --- | --- |
| Introduction / interpretation | 1–19 | 278–347 |
| A1 Profile | 20–24 | 348–374 |
| A2 Trust | 25–27 | 375–384 |
| A3 Schemas / relations | 28–34 | 385–414 |
| A4 Injection / files | 35–41 | 415–437 |
| A5 Resources / ReDoS | 42–48 | 438–462 |
| A6 Authentication | 49–53 | 463–478 |
| A7 Recovery | 54–58 | 479–500 |
| A8 Authorization | 59–63 | 501–517 |
| A9 Cryptography | 64–70 | 518–546 |
| A10 Memory | 71–75 | 547–566 |
| A11 Privacy | 76–82 | 567–582 |
| B1 API boundaries | 83–87 | 583–607 |
| B2 Tenancy | 88–94 | 608–633 |
| B3 Concurrency | 95–103 | 634–683 |
| B4 Time / consistency | 104–108 | 684–702 |
| B5 Money / ledger | 109–115 | 703–731 |
| B6 Idempotency / webhooks | 116–122 | 732–766 |
| B7 Workers | 123–125 | 767–780 |
| B8 Infrastructure / SSRF | 126–134 | 781–807 |
| C1 Rendering | 135–139 | 808–834 |
| C2 Browser sessions | 140–142 | 835–846 |
| C3 Third parties | 143–147 | 847–862 |
| D1 Native trust | 148–150 | 863–872 |
| D2 Storage / backup | 151–157 | 873–905 |
| D3 Native files / UI | 158–162 | 906–923 |
| D4 OAuth / links | 163–167 | 924–945 |
| D5 IPC / shared memory | 168–172 | 946–971 |
| D6 Loopback | 173–175 | 972–985 |
| D7 Offline / sync | 176–180 | 986–1006 |
| D8 Lifecycle | 181–183 | 1007–1017 |
| E Windows E1–E5 | 184–192 | 1018–1067 |
| F Android F1–F5 | 193–202 | 1068–1135 |
| G macOS G1–G5 | 203–211 | 1136–1194 |
| H Frameworks H1–H2 | 212–218 | 1195–1228 |
| I1 Updates | 219–221 | 1229–1243 |
| I2 Supply chain | 222–224 | 1244–1257 |
| I3 Audit / response | 225–228 | 1258–1274 |
| I4 Disaster recovery | 229–233 | 1275–1291 |
| I5 Mixed versions | 234–236 | 1292–1303 |
| I6 Performance | 237–241 | 1304–1320 |
| J Testing J1–J3 | 242–254 | 1321–1427 |
| J Standards / evidence J4–J5 | 255–262 | 1428–1455 |
| J Exceptions / output J6–J7 | 263–277 | 1456–1503 |

For active Security review, A/I/J are the universal profiles; determine which
controls within them apply. Add B for backend/shared data/finance, C for web,
D for native, E/F/G for actual OS targets, H for native bridges/frameworks.
An Electron/backend task needs A/B/C/D/H/I/J and its target OS sections.
Do not omit platform and recovery details just because an automated scan is clean.
