# Luna Light Engagement Template

Use this prompt with a current eligible Luna Light route:

    Use the fugu-free-model-fleet-operator skill for this bounded task.

    Mission: refresh and, only where proven safe, update the exact free-model fleet across Fugu, Hermes, OpenCode, and T3 Code.

    Read first:
    1. <AI_WIKI_ROOT>/04_skills/agent-skills/skills/fugu-free-model-fleet-operator/SKILL.md
    2. <AI_WIKI_ROOT>/04_skills/agent-skills/skills/fugu-free-model-fleet-operator/reference/operational-contract.md
    3. <AI_WIKI_ROOT>/04_skills/agent-skills/skills/fugu-free-model-fleet-operator/reference/luna-light-runbook.md
    4. the newest snapshot under <AI_WIKI_ROOT>/05_Outputs/fugu-free-model-fleet/

    Use only the current Fugu adapter and exact provider/model identities. Do not bypass the adapter, use paid fallback, edit T3 userdata, read secrets, print .env values, hand-edit generated manifests, publish/deploy, or modify unrelated dirty work. Run snapshot, plan, stage, dry-run, exact no-fallback/no-child canaries, receipt review, manifest regeneration, and acceptance in order. Stop and report NOT RUN when a required gate is unknown.

    Return the required PASS/PARTIAL/FAIL evidence packet with paths, hashes, route decisions, receipts, failure classes, T3 UI status, rollback status, and one next action.
