# Transcript-Derived Patterns

These notes distill the two supplied transcripts into operational rules for skill creation.

## Pattern 1: Prompt skills, not the base model

Repeated prompts should become reusable skills. The useful mental shift is from "write a big prompt every time" to "create a durable capability and invoke it."

Operational rule:

- When a user repeats a workflow, create or update a skill.
- When the user only needs a one-off answer, do not overbuild.

## Pattern 2: Skills are more than prompts

A useful skill has:

1. description / discovery metadata
2. procedural instructions
3. optional tools, scripts, templates, and references

Do not stop at pretty prose. If structure or validation repeats, make it a file or script.

## Pattern 3: Build composable skills

Avoid one giant content/business/research/design skill that handles everything. It becomes hard to debug and improve.

Split skills by:

- trigger context
- risk level
- reusable function
- artifact type
- tool permission
- update cadence

## Pattern 4: Save repeat scripts inside skills

If Claude repeatedly writes the same Python/Node/PowerShell helper, save it under `scripts/` and tell the skill when to run it.

Examples:

- validate `SKILL.md`
- generate a tree
- package a folder
- inspect frontmatter
- crop/check assets
- transform transcripts into structured notes

## Pattern 5: Control who invokes what

Design side-effect boundaries:

- direct user invocation for risky operations
- model invocation for safe background knowledge
- no broad pre-approved tools unless reviewed

This matters for deployment, sending messages, deleting files, external API access, and production writes.

## Pattern 6: Skills should compound

After a skill run:

- If the correction was one-time, leave the skill alone.
- If the correction should recur, add a small rule, example, eval, reference, or script.

## Pattern 7: Skill creator flow

A good meta-skill should:

1. let the user describe the desired skill in plain language
2. ask only necessary clarifying questions
3. generate the skill folder and files
4. improve existing skills
5. optimize descriptions
6. add references when research is needed
7. save outputs where the user can review them

## Pattern 8: Business-use skills are boring on purpose

The sticky examples were not magic. They were repeated operational workflows:

- daily planning
- video analysis
- newsletter digestion
- article conversion
- decision memos

A skill is worth building when it saves repeated attention, not merely when it looks clever.
