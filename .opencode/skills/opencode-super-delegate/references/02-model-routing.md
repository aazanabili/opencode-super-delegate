# Hierarchical model routing and one-time approval

Read [hierarchy](14-cost-hierarchy.md). L0 is the user's premium host model;
do not call another premium planner by default. Discovery is capability metadata,
not permission to make unapproved provider requests.

1. Check installed `opencode --version`, `opencode models --help`, then
   `opencode models` as supported. Do not refresh remotely or probe every model.
   When supported, `opencode models --verbose` exposes catalog metadata including
   costs. Filter it into a small relevant candidate table instead of forwarding
   the complete catalog to L0; catalog prices may differ from billing terms.
2. Listing indicates a model catalog, not valid credentials, entitlement, price,
   tool reliability or remaining quota. Use configured provider information and
   user-known pricing; label unknown cost/capability explicitly. Do not expose keys.
3. Propose L1 planning/coordinator and independent review leads cheaper than L0;
   L2 implementers/reviewers cheaper than their leads; L3 mechanical helpers
   cheaper again, only where delegation has a net benefit.
4. For each role state exact provider/model ID, estimated relative cost and its
   source/uncertainty, task fitness, allowed child roles/models, permissions,
   allowed fallbacks, variant if supported, and budget. Providers are unrestricted
   within available access: hosted, gateways, subscriptions or local endpoints.
5. Prefer an approved DeepSeek or Flash-class option for bounded correction when
   suitable; correction must differ from the failed implementer's model. A brand
   alone is not evidence of cost, quality, or independence.

Always obtain one interactive approval before delegated planning or execution.
It covers the hierarchy, permitted child edges, automatic fan-out within limits,
budget caps, branch strategy, permission ceilings, correction capabilities and
Git side effects. No YAML switch may disable it. Approval of a family of bounded
tasks permits routine allocation without repeated questions.

If price ordering is unknown, disclose it and obtain approval of an explicit
relative tier map; never claim measured savings. Do not choose a more expensive
or unlisted fallback silently. After approval, a minimal first real task can
verify access. Authentication/rate-limit failures are environment findings,
not permission to switch providers or retry indefinitely.

Changes outside approved scope/ceilings need a focused decision. Inside those
bounds, L1 may select approved cheaper children/fallbacks autonomously. Escalation
to L0 supplies a report for decision, not automatic premium implementation.
