# CLAUDE.md · Instructions for every team member's AI agent

You are helping a 3-person university team build **Connect Four Flip**: a physical Connect Four board driven by an Arduino with motors, plus a ProtoPie GUI, with two-way communication. Course: Hardware and Software Technologies for Design.

## The team

- **Nobody has prior experience** with electronics, mechanics or programming. Explain like a patient tutor: short steps, why before how, define jargon once, give exact wiring (pin → pin) and complete code, and suggest how to test each step before the next.
- Prefer the simplest approach that works over the clever one. Always protect a working version.

## Read before answering

1. `docs/01-brief.md`: what the course asks for
2. `docs/02-game-rules.md`: **the rules are the source of truth**
3. `DECISIONS.md`: what's already decided; don't re-open decisions without saying so
4. `TASKS.md`: what's being done and by whom
5. Then the area doc you need: `docs/03-hardware.md`, `docs/04-software.md`, `docs/05-learning-path.md`

## Facts that must stay consistent

- Board 7 columns × 6 rows; row 0 = bottom, column 0 = left; red = P1 (human in single player), yellow = P2 (computer).
- Arduino owns the game state, rules, AI and score; ProtoPie only displays and sends choices.
- Messages are `MESSAGE||VALUE` lines; the full table is in `docs/04-software.md`. If you add or change one, update that table and both sides.
- The flip reverses each column's coin order; columns don't swap. Winner after a flip: most lines of 4+; tie → the flipper; none → keep playing.

## When you change things

- Rule change → update `docs/02-game-rules.md` (and, once code exists, the code and its tests in the same commit).
- Any decision → add an entry at the top of `DECISIONS.md`.
- Finished or started work → update `TASKS.md`.
- Follow `docs/06-collaboration.md` for the update rules. At the end of a session, offer to update the context files and write the commit message.

## Don't

- Don't power servos from the Arduino 5 V pin; always an external supply with common ground.
- Don't put big binary files (videos, CAD exports) in git; link them from the docs instead.
- No code has been written yet (team decision, 2026-10-07). When code is added, put Arduino code in `arduino/` and ProtoPie files in `gui/`, and update `docs/04-software.md`.
- Don't claim hardware code works unless it was run on the real board; say "untested on hardware".
