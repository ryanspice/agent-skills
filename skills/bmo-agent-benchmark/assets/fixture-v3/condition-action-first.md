# Action-first postcondition-gated execution condition

This condition changes execution scheduling only. Product requirements, source
data, safety boundaries and acceptance criteria remain identical.

## Action invariant

1. Perform at most one batched repository inspection before editing.
2. Make the first Write or Edit no later than the second assistant/tool cycle.
3. Establish the integration spine first:
   - replace the starter `src/routes/+page.svelte`;
   - add the typed source-data module;
   - add shared design tokens;
   - keep every new component reachable from the root route.
4. Never leave disconnected leaf components as the apparent result.
5. Never call a terminal, browser, web service, MCP tool, process or child
   agent.

## Postcondition gates

Complete each gate in order and continue immediately when its files exist:

1. `SPINE`: root route renders the disclosure, header shell, deterministic
   hero and typed data.
2. `BREADTH`: root route reaches all six tabs and all 36 cards.
3. `SECTIONS`: app banner, three help cards and grouped footer are wired.
4. `BEHAVIOUR`: safe sign-in, mobile navigation, tabs, focus, Escape handling
   and reduced-motion behaviour are present.
5. `STATIC-AUDIT`: inspect only changed files and repair obvious import,
   Svelte, TypeScript, markup and missing-content defects.

Do not narrate a plan between gates. Do not issue a completion-style response
while the starter route remains, required content is absent, or created files
are unwired. Under pressure, reduce decorative component granularity before
dropping content, integration, safety or accessibility.
