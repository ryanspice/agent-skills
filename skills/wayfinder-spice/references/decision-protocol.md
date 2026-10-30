# Decision protocol

## One authority, not three boards

Use the project's existing tracker and lane conventions. Record the canonical map
location and revision in the handoff. A GitHub-backed effort uses one map issue and
named decision issues; use native sub-issues/dependencies only after tool capability
is established. New issue/label creation is an external write requiring authorization.
A task list in an issue body is not a native blocking relationship.

When no suitable tracker exists, propose a local map under the existing project
planning directory. `.thoughts/wayfinder/<effort>/` is a fallback, not a mandatory tree.
The local map is an index; each decision is its own Markdown file with the template's
metadata and sections. No database, new service, or automated tracker is required.
Without filesystem write permission, output proposed Markdown without claiming it exists.

## Identity and minimum records

A decision needs a stable identity, readable title, type, mode (agent/human), status,
explicit dependency identities, owner/session claim, exact question, resolution bar,
evidence pointers, and disposition. Use issue IDs for tracker identity or stable
filenames for local identity. Titles can change without changing identity.

Statuses: `open`, `claimed`, `waiting-human`, `blocked`, `resolved`, `out-of-scope`,
`superseded`. In a two-state tracker, metadata records the additional states.
`waiting-human` and `blocked` are not closed resolutions. The existing lane system
may map these names to equivalent states; do not impose new labels unnecessarily.

Types: research, prototype, decision, prerequisite. Agent mode does not grant spending,
account, installation, publishing, or destructive permissions. A human-mode ticket
cannot resolve by the agent supplying an imagined answer or accepting its own mockup.

An accepted conclusion may be **proceed**, **do not proceed**, or **reuse/no change**.
A negative result is valuable when it answers the question with adequate evidence.

## The frontier

A ticket is eligible when it is open, has no active claim, and every required decision
has a current accepted resolution. The frontier is queried or derived from tickets;
do not maintain an independent manually edited open-ticket list in the map.

“Closed” is not enough: out-of-scope and superseded dependencies must be rewired or
explicitly removed. A resolved dependency that has become stale blocks affected
choices until its continuing validity is checked. Optional observations are not blockers.

Reject self-links, missing identities, duplicate identities, and dependency cycles.
When a cycle exists, name it and split the smallest common prerequisite or reframe the
questions. Do not close a ticket just to make the graph look green.

## Claims and concurrency

Use one coordinator as the only map, claim, and shared-ledger writer. Native assignment
communicates ownership but is not a compare-and-swap lock. Two sessions from Ryan can
have the same assignee, so record a distinct session identifier and scope as well.

Before work: coordinator reads current state, reserves the eligible ticket in the
existing coordination mechanism, records owner/session/UTC timestamp, and rereads
ownership. Use a proven lease/locking service only if one already exists. A Markdown
claim plus reread is not atomic; local Markdown mode therefore remains single-writer.
Workers return receipts to the coordinator; they do not mutate shared map state.

A stale timestamp is a reason to investigate, not permission to steal a claim. Contact
the known coordinator/session when possible; reclaim only under the repo's recovery
policy or explicit owner direction. Preserve previous claim history and work pointers.
Without a trustworthy lock or coordinator, serialize work rather than pretend it is safe.

Parallel read-only investigations may use separate source contexts. Authorized code
writers need non-overlapping scopes and the isolation required by the established
lane workflow. Coordinated shared-checkout claims remain valid where that workflow
permits them; this skill does not impose a blanket worktree requirement. Browser, release, provider-config, and ledger writes have a single owner.

## Resolution transaction

1. Re-read the ticket, dependencies, and current repo revision.
2. Append the resolution, supporting evidence, caveats, and acceptance/authority.
3. Mark the correct disposition only after the resolution bar is met.
4. Update the map's named one-line index entry without duplicating full rationale.
5. Reconcile dependants and newly precise fog. Retain superseded records.
6. Re-read the affected state and record the resulting reference.

For GitHub, put the resolution in an issue comment and link it from the index. For
local Markdown, put it in the ticket's Resolution section. Neither is duplicated in
both places. Retrying a failed update starts by reading current state: do not create
another ticket or duplicate a resolution comment blindly.

## Evidence freshness and reversibility

Record the relevant source revision, environment/versions when material, and access
or observation date. Revalidate when a premise changes: dependency version, contract,
user intent, device target, provider route, auth mode, data shape, or a failed acceptance
check. A new unrelated commit does not automatically invalidate every old decision.

For a consequential choice, state what would falsify it and how to undo or replace it.
This is a practical rollback/revisit condition, not an exhaustive ADR for every detail.
If the destination changes, record a scope revision or open a linked effort. Excluded
work returns only through that explicit scoping action, not by silently renaming it fog.

## Completion

Decision-ready requires no unresolved in-scope blocker or unexamined in-scope fog,
all required human choices accepted, valid dependencies, current decisive evidence,
and a bounded implementation handoff. Explicitly list non-blocking risks and who
accepted them. Ready to implement, implementation complete, CI green, installed, and
accepted on hardware are different claims.
