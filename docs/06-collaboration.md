# 06 · How we work together (and keep the context up to date)

This repo is the shared brain. Each teammate's Claude (Claude Code, or Claude on claude.ai/desktop with this repo connected) reads `CLAUDE.md` first, then the docs, so everyone's agent starts from the same facts.

## Setup per teammate (once)

1. Create a GitHub account and send Danny your username. Danny adds you: repo **Settings → Collaborators → Add people**.
2. Install **GitHub Desktop** (easiest, no command line) and clone the repo. Or use Claude Code, which can clone it for you.
3. Point your Claude at the repo folder (Claude Code: open it in that folder; claude.ai: connect GitHub and pick the repo).

## Daily loop

1. **Pull** (GitHub Desktop: "Fetch origin" → "Pull") so you have everyone's latest changes.
2. Pick a task from [TASKS.md](../TASKS.md), put your name on it.
3. Work. Ask your agent for help; it already knows the context.
4. **Update the context** (below) in the same commit as your work.
5. **Commit** with a clear message ("Wire sensors for columns 0-3", not "stuff") and **push**.

## The context-update rule

When you finish something, ask your agent: *"Update the repo context for what we just did."* It should:

| If you… | Update |
|---|---|
| finished or started a task | `TASKS.md` (status, name, date) |
| made or changed a choice (part, rule, pin, approach) | `DECISIONS.md` (new entry at the top) |
| changed a rule | `docs/02-game-rules.md` (and the code, once it exists) |
| changed wiring or parts | `docs/03-hardware.md` |
| changed messages or code structure | `docs/04-software.md` |
| learned something the hard way | "Lessons learned" in `TASKS.md` |

Keep docs describing **what is true now**; history goes in `DECISIONS.md` and git.

## Avoiding conflicts

- Each person mostly owns different files (see roles in `TASKS.md`). Two people editing the same file at once causes merge conflicts.
- Pull before you start, push when you stop. Small commits often.
- For bigger changes, use a **branch + pull request** so someone else glances at it first. GitHub Desktop has a "New branch" button.

## Other ways to collaborate (alternatives or extras)

- **GitHub Issues + Projects board** instead of `TASKS.md`: nicer kanban, but agents read a file in the repo more easily. Fine to use both.
- **A shared Claude project on claude.ai**: requires a Claude Team/Enterprise plan to share with teammates. Danny's current project is personal and can't add members, which is why we use this repo.
- **Google Drive / Notion** for photos, videos, CAD files, slides: put big binary files there and link them from the docs. Git is bad at huge files.
- **Wokwi** projects can be shared by link for circuit simulations.
- **A weekly 15-minute sync** (call or in person): agents don't replace agreeing on what's next.
