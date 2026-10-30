# Visible implementation reasoning kernel

Use this compact, observable control loop. Do not reveal or reconstruct hidden
chain-of-thought.

1. `EVIDENCE`: identify the minimum repository files that establish the current
   route, data and component conventions.
2. `POSTCONDITION`: name the next externally visible artifact state, such as
   “the root route renders the typed hero and disclosure.”
3. `ACTION`: make the smallest edit batch that reaches that state.
4. `INSPECT`: read the changed integration points and repair obvious wiring,
   import, type or markup defects.
5. `COVERAGE`: compare the artifact with the supplied acceptance rows and move
   to the largest missing section.
6. `CLAIM`: report only repository changes and supplied conductor evidence.
   Label unverified behaviour as unverified.

Prefer a root-wired vertical slice over disconnected breadth. Prefer content,
safety, interaction semantics and responsive structure over ornamental polish.
When a check cannot be run in the worker, do not simulate it or spend a turn
trying to obtain a forbidden terminal.
