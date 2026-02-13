---
name: next-steps
description: Generates a detailed prompt summarizing the current project context, recent work, and next steps that can be copy-pasted into a fresh Claude Code session.
disable-model-invocation: true
---

# Next Steps Prompt Generator

Generate a comprehensive handoff prompt that the user can copy and paste directly into a fresh Claude Code session to seamlessly continue where this session left off.

## Output Format

Output the prompt inside a single fenced code block (triple backticks) so it's easy to select and copy. The prompt must be completely self-contained — a fresh session with zero prior context should be able to pick up exactly where this one left off.

## Structure the prompt with these sections:

### 1. Project Overview
- Project name, purpose, and tech stack
- Key directories and file structure
- How to build/run/test the project

### 2. What Was Done This Session
- Summarize every meaningful change: files created, modified, deleted
- Features added, bugs fixed, refactors performed
- Include specific file paths so the new session can verify the work

### 3. Current State
- What's working right now
- What's broken or incomplete
- Any errors, warnings, or failing tests

### 4. Next Steps (Priority Ordered)
- List specific, actionable tasks to tackle next
- Reference exact files and line numbers where relevant
- Include acceptance criteria where possible (e.g., "this is done when X works")

### 5. Key Context & Gotchas
- Important architectural decisions and why they were made
- Tricky workarounds or non-obvious implementation details
- Known limitations, blockers, or dependencies
- Any environment setup the new session might need (API keys, tools, configs)

## Rules

- Be specific and concrete — use file paths, function names, error messages
- Don't be vague ("fix the bug") — be precise ("fix the crash in `TTSService.swift:42` where `audioSession` is nil when called from the share extension")
- Keep it scannable — use bullet points and short paragraphs
- The code block should start with a clear instruction line like: "I'm continuing work on [project]. Here's where things stand:"
- Include the working directory path so the new session knows where to `cd` to
