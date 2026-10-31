---
name: blender-mcp
description: Create, inspect, and edit Blender scenes and assets through Blender MCP tools in T3 Code. Use for general Blender work when MCP control is requested or available, including patient startup and reuse of a single Blender instance and MCP server.
metadata:
  status: unfinished
  provenance_origin: original
  provenance_source_path: 04_skills/agent-skills/skills/blender-mcp/SKILL.md
  provenance_credit: Ryan Spice-Finnie
  provenance_note: Original Blender MCP workflow authored for Ryan's AI Wiki and T3 Code.
---

# Blender through MCP

Status: **unfinished**. See [STATUS.md](STATUS.md) for evidence and remaining
checks. Use the Blender MCP tools exposed to the current T3 Code session for
the requested Blender work. This skill is independent of any game or project.

## Connect once and wait for readiness

1. Confirm the user's target machine and discover its actual Blender MCP tools,
   schemas, and connection status. A T3 conversation bridge is for thread
   communication; it does not itself provide Blender control. Do not invent a
   server name, endpoint, port, tool, or launch command.
2. Maintain **one Blender application instance and one Blender MCP server for
   that machine**. Inspect existing instance/server state before launching
   anything, using the available tools or bounded read-only process and
   connection checks on that machine. Reuse the existing instance and server.
   The add-on listener inside Blender and its MCP bridge are parts of the same
   connection, not two duplicate Blender instances. Identify the actual
   integration before deciding that a component is redundant.
3. If duplicates exist, identify their owning sessions and unsaved work first.
   Reconcile only duplicates whose shutdown is authorized and whose work is
   preserved. Never blanket-kill Blender or MCP processes, and never restart
   another task's busy instance. If safe reconciliation cannot be established,
   report the conflict and do not launch another instance.
4. If no instance/server exists, use the installed integration's documented,
   authorized startup path once. Allow Blender, the add-on, and a loaded file
   to become ready before submitting scene work. Starting a process is not
   proof of readiness: confirm a successful lightweight MCP scene/status call.
   If available tools cannot establish instance count or readiness, report
   that limit rather than claiming the single-instance check passed.
5. Be patient with startup, file loads, renders, and long operations. Follow
   the tool's returned wait/resume mechanism and inspect progress without
   issuing duplicate commands. Use short waits, normally 10-30 seconds and
   never a blocking wait over 60 seconds, with user updates during long work.
   Allow several minutes when appropriate to the operation and machine;
   establish a reasonable task-specific limit and extend it when observable
   progress justifies doing so. A slow reply is not a reason to relaunch.
6. After a timeout or dropped connection, first determine whether the original
   operation is still running or already succeeded. Do not blindly retry a
   mutation, launch another server, or start another Blender. Report the exact
   error and the state you can establish; recovery must preserve ongoing work.
   If MCP remains unavailable, report what connection is needed. Do not
   silently replace requested MCP work with background Blender, shell-driven
   scene edits, GUI automation, another machine, or another provider. Installing
   or reconfiguring the server/add-on requires authorization beyond using it.

## Work on the scene

- Inspect the active file, scene, selection, and relevant object state before
  changing existing work. Resolve an ambiguous target before changing it.
  Preserve unrelated objects and unsaved work; create a recovery copy before
  consequential edits without overwriting the original.
- Make the requested geometry, material, lighting, animation, or export changes
  in coherent steps through the actual MCP capabilities. Python executed by an
  exposed Blender MCP tool is valid MCP work; an external Blender CLI run is a
  different execution path. Handle paths and external assets explicitly.
- Serialize scene mutations, file loads, and renders through the one connection.
  Wait for each operation to settle before sending a dependent one. Treat a
  timed-out mutation as uncertain until inspection resolves its result.
- Verify relevant scene properties and saved/exported files. For visual work,
  inspect an actual render or viewport capture when supported. Distinguish
  scene checks, MCP execution, visual inspection, downstream import, and human
  acceptance. Report unsupported checks honestly.

Report what changed, artifact paths, actual verification, and remaining limits.
Leave the user's Blender session and saved work available unless closure was
requested. Do not send work to another thread or machine without user direction.
