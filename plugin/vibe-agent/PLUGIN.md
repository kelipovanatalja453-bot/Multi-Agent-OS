# vibe-agent plugin

A plugin bundling skills for multi-LLM-agent coordination.

## Skills

| Skill | Status | Loads when |
|---|---|---|
| core-coordination | ✅ v0.1 | Any multi-agent project. Identity, tiers, handoff, task card, report, red lines. |
| task-handoff | ⏳ planned | (v0.2) Complex cross-agent delegation. |
| review-verify | ⏳ planned | (v0.2) R3+ review and evidence verification. |
| quota-routing | ⏳ planned | (v0.2) When quota-aware scheduling matters. |
| multi-agent-parallel | ⏳ planned | (v0.2) Parallel agents with ownership boundaries. |

v0.1 ships only `core-coordination`. Others are added when real use proves
they're needed (see DECISIONS.md D1, D9).

## Config

Copy `presets/my-setup.example.yaml` to `presets/my-setup.yaml` and fill in
your own model pool and quotas. The plugin reads this to map capability tiers.
