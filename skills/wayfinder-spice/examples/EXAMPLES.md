# Examples — illustrative, not repository findings

These show how to use the skill against Ryan's kinds of work. They are not claims
that these repos were inspected, bugs reproduced, devices tested, or decisions accepted.

## WebOS: overlay remains after resume

Prompt: “Use WAYFINDER to plan the Twitch WebOS resume/raid fixes. Do not edit the app.”

Destination: an evidence-backed lifecycle fix plan with separate installed-TV acceptance.
First research ticket: **Which event/state path leaves the overlay visible after resume?**
Read lifecycle handlers, subscriptions, timer ownership, focus transitions, and tests.
Resolution needs a source-backed event sequence, or a precise missing trace—not a guess
that a timeout is broken. A disposable event trace requires appropriate execution scope.

Then decide **Where should overlay visibility and its cleanup be owned?** using the
observed architecture. Raid handling and discovery UI are separate decisions unless
evidence proves a shared dependency. “Show another stream during ads” does not silently
enter the resume-fix scope. A host-browser result is not a TV-installed result.

## Svelte: a clear two-file fix

Prompt: “Fix this known form error and add the regression test.”

Correct route: no map. Inspect local rules and relevant source, preserve the package
manager, make the bounded authorized change, and run the discovered check. No framework
migration, architecture interview, or deployment. The skill should not auto-trigger.

## PixelBoats: rough material versus production

Prompt: “WAYFINDER this rough game demo into an intro sequence.”

Destination: decide sequence structure, assets needed, transition behavior, and acceptance
before production integration. A sketch may be useful, but label simulated gameplay and
placeholder assets honestly. Resolve narrative/visual preference with Ryan where needed.
Keep the WIP archive as proposed material. Do not import it into Svelte Lab, overwrite
working game code, or convert an aesthetic decision into invented human acceptance.

## PocketMic-style cross-platform release

Prompt: “Map what must be decided before these Windows/Android installers are ready.”

Separate version/scope authority, hosted build evidence, package identity, upgrade behavior,
installation, and physical acceptance. Passing JVM/.NET unit tests is evidence for those
checks, not proof that installed audio works. Preserved Apple work need not be discarded
or promoted into this release's acceptance scope. Read the actual release intent first.

## Provider tooling: apparent free route

Prompt: “Can this optional model handle the research tickets?”

Destination: establish whether the approved optional route has the tools, identity,
reliability, and budget needed for this bounded role. A model picker entry or 401 is
not a capability result. Preserve working defaults. No account creation, paid fallback,
or auth/config rewrite to obtain a canary. When blocked, return the precise missing
permission/capability and an independent read-only task that can still be completed.
