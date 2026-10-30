# BMO Personal homepage reference implementation benchmark

## Mission

Build a high-fidelity, responsive, local-only front-end recreation of the public BMO Canada Personal Banking homepage.

Use `bmo-home-source-brief.json` as the authoritative source. **Do not browse the web, scrape BMO, inspect the original 5.3 MB HTML, or spend turns reverse-engineering generated class names.** The brief already contains the semantic page tree, campaign data, tokens, assets, links and acceptance checks.

## Safety and scope

This is a UI/reference demo, not a banking product.

- Add a visible `REFERENCE DEMO — NOT BMO` disclosure.
- Do not collect account numbers, passwords, card data, personal information or credentials.
- The Sign In control opens a clearly non-functional demo panel; it must not contain credential fields.
- Do not call BMO APIs.
- Do not reproduce analytics, Adobe tags, OneTrust, geolocation, personalization, chatbots or tracking.
- Do not deploy or configure a deceptive domain.
- Keep external links as ordinary links, but prevent the demo from implying that actions occurred locally.

## Required stack

Use the existing repository if one exists. Otherwise use:

- SvelteKit 2
- Svelte 5 runes
- TypeScript with strict checking
- Semantic HTML and scoped CSS
- No Tailwind, component framework or heavy carousel dependency
- Minimal dependencies
- Progressive enhancement: core content remains readable without JavaScript

Suggested files:

```text
src/
  lib/
    components/
      BmoHeader.svelte
      MegaMenu.svelte
      MobileDrawer.svelte
      HeroCampaign.svelte
      NeedsNavigator.svelte
      ProductCard.svelte
      AppBanner.svelte
      HelpChooseGrid.svelte
      BmoFooter.svelte
      DemoDisclosure.svelte
    data/
      bmo-home.ts
    styles/
      tokens.css
  routes/
    +page.svelte
    +page.ts
static/
  favicon.svg
```

Convert the supplied JSON manifest into typed data in `src/lib/data/bmo-home.ts`. Do not scatter copy, links or asset URLs through components.

## Page architecture

Render these sections in order:

1. Optional compact informational alert.
2. Responsive utility header and main navigation.
3. One weighted hero campaign.
4. “What can we help you find today?” needs navigator.
5. Mobile banking application split banner.
6. “Not sure where to begin? We’ll help you choose” three-card section.
7. Large blue footer.

### Header

Desktop:

- Utility row: Personal selector, search, Canada selector, EN selector and Sign In.
- Main row: BMO logo followed by Bank Accounts, Credit Cards, Mortgages, Loans, Investing, Insurance, Offers & Programs.
- Implement one reusable accessible mega-menu pattern and populate concise representative links. Do not recreate the full several-hundred-link sitemap.
- Search expands in place.
- Sign In opens a demo-only popover with disabled destination choices.

Mobile/tablet:

- Logo, Sign In and hamburger.
- Drawer contains utility controls, search and accordion navigation.
- Trap focus only while the drawer is open; restore focus on close.

### Hero

The source contains a **weighted campaign pool**, not a seven-slide user-facing carousel.

- Render one campaign per page load.
- Use `investment-contest` as the deterministic default.
- Support `?hero=<campaign-id>` on localhost for visual testing.
- Desktop uses a balanced content/image split.
- Mobile stacks content and image.
- Preserve semantic heading, supporting copy, CTA and responsive image sources.
- Do not auto-rotate.

### Needs navigator

- Heading: “What can we help you find today?”
- Tabs: Featured, Bank Accounts, Credit Cards, Mortgages, Investments, Learning.
- Six cards per tab from the supplied manifest.
- Three columns on desktop, two on tablet, one on mobile.
- Tabs scroll horizontally on narrow screens.
- Use a moving blue active indicator, correct `tablist`/`tab`/`tabpanel` semantics, arrow-key navigation and managed focus.
- Card variants are white, albicant and ultramarine. Ultramarine cards use white text.
- Preserve source card headings, summaries, CTA labels and links.

### App banner

- Two-column copy/image section; stack on mobile.
- Include Apple App Store and Google Play badges.
- Preserve the supplied device image and alt text.
- Use generous white space and a clear blue text CTA.

### Help-me-choose section

- Pale white-to-polar gradient.
- Centred heading.
- Three equal cards: Bank accounts, Credit cards and Investments.
- Each card has an illustration placeholder or lightweight inline SVG, a short explanation and Help me choose CTA.

### Footer

- Brand-blue background with white text.
- Responsive grouped link columns.
- Include compact groups for services, security, ways to bank, downloads, contact, social and corporate/legal.
- Include customer support, branch locator and appointment actions.
- Include a compact placeholder CDIC disclosure.
- Do not duplicate all legal text from the source.

## Visual system

Use the exact token values from the JSON manifest.

Key rules:

- Heebo, Arial, sans-serif.
- Base text 16px/24px.
- Strong dark slate text on white.
- BMO brand blue for links, active states and footer.
- Accessible dark blue for hover/focus.
- Cards use 8px radius; menus approximately 10px.
- Content max width approximately 1204px within a 1440px page shell.
- Gutters: 24px mobile, 32px tablet, up to 120px wide desktop.
- Breakpoints: 768px, 1024px, 1268px and 1440px.
- Avoid shadow-heavy, glassy or generic AI-generated styling. Match the restrained institutional layout.

## Accessibility

- One meaningful page `h1`; logical heading order afterward.
- Skip link.
- Visible focus styles.
- Keyboard-operable tabs, menus, drawer and demo dialog.
- `aria-expanded`, `aria-controls`, labelled regions and live announcements only where useful.
- Escape closes overlays.
- Decorative images use empty alt text; meaningful images use supplied alt text.
- Respect `prefers-reduced-motion`.
- Minimum 44px touch targets where practical.
- Do not remove outlines without a replacement.

## SEO

Set:

- `lang="en-CA"`
- Page title from the manifest
- Meta description from the manifest
- Canonical `https://www.bmo.com/en-ca/main/personal/`
- Basic WebSite JSON-LD with a search action
- Responsive viewport metadata

## Engineering requirements

- Svelte 5 runes only; no legacy reactive syntax in new components.
- Typed props and data models.
- No `any` unless isolated and justified.
- Keep components small and data-driven.
- No generated BMO CSS class names.
- No copied Next.js runtime, CMS payload, third-party scripts or tracking markup.
- Centralize remote assets and provide gradient/colour fallbacks if an image fails.
- Avoid layout shift by supplying image aspect ratios.
- Lazy-load below-the-fold images.
- Hero image may be eager/high priority.
- Avoid unnecessary hydration.

## Bounded execution

The cell-specific task packet sets the exact tool-turn cap. Do not use turns
for research or plan narration. Use file tools to implement a continuously
wired page in this order:

1. Inspect the minimum scaffold files, establish typed data and tokens, and
   replace the starter route with a working page shell.
2. Build the responsive header, menus, drawer, safe demo sign-in state and
   weighted single-campaign hero.
3. Build the six-tab navigator with all 36 cards and keyboard behaviour.
4. Build the app banner, help section and footer.
5. Repair responsive, accessibility, type and integration defects by
   statically inspecting the files you changed.

The worker has no terminal, browser, web or child-agent capability. Never spend
a turn trying to invoke one. The outer benchmark conductor owns deterministic
checks and browser verification after each cell.

## Verification split

The outer conductor, not the delegated worker, runs:

```powershell
npm install
npm run check
npm run build
npm test
```

The worker must statically self-audit its files for:

- No console errors.
- No horizontal scrolling at target widths.
- Menus, tabs and drawer work by keyboard.
- Sign In cannot accept or transmit credentials.
- Remote image failure does not collapse layout.
- All acceptance checks in `bmo-home-source-brief.json` pass.

Do not claim that a check, build, browser test or interaction passed unless the
task packet explicitly supplied that result as conductor evidence.

## Completion response

Return:

1. What was implemented.
2. Files created or changed.
3. Static checks performed and conductor evidence used.
4. Any deliberate differences from the public reference.
5. The single highest-value next improvement.

Start implementing immediately. Do not browse, call a terminal, narrate an
extended plan or ask for the original HTML.
