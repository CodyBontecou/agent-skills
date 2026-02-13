# Next Steps

Generate a detailed handoff prompt summarizing the current project context, recent work, and next steps that can be copy-pasted into a fresh Claude Code session to seamlessly continue where the current session left off.

## What It Generates

A self-contained prompt inside a fenced code block with:

1. **Project Overview** — Name, purpose, tech stack, key directories, how to build/run/test
2. **What Was Done** — Files created/modified/deleted, features added, bugs fixed
3. **Current State** — What's working, what's broken, errors/warnings
4. **Next Steps** — Priority-ordered actionable tasks with file paths and acceptance criteria
5. **Key Context** — Architectural decisions, workarounds, gotchas, environment setup

## Usage

This skill is invoked automatically when the user asks to generate a handoff prompt or "next steps" for continuing work in a new session. No scripts or setup required.

See [SKILL.md](./SKILL.md) for the full output structure and rules.
