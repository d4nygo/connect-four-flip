# Decisions log

Newest at the top. Each entry: date, decision, why, who. Marked **(default)** = picked by Claude to keep moving; the team can change it.

---

### 2026-10-07 · Patterns must match exactly (Danny)

- **A pattern must be built exactly as drawn.** A left-right mirror counts; a rotated or upside-down version does not.
- **FLAT L** (the sideways L) is its own pattern. Patterns are now BOX, T, L, FLAT L, ZIGZAG.

### 2026-10-07 · Flip pattern visible, 4 coins (Danny)

- **The pattern is visible again**, not secret: chosen (or randomised) at setup and shown all game. Why: it encourages players to build the pattern on purpose. Replaces the "secret pattern" entry below.
- **Every pattern is exactly 4 coins and never a straight line.** Patterns: BOX, T, L, ZIGZAG ~~in any rotation or mirror~~ (see entry above). DIAGONAL3 dropped (only 3 coins); PYRAMID is now called T.

### 2026-10-07 · Answers from Danny

- **Board: standard 7×6** confirmed.
- **GUI: ProtoPie** confirmed. UI and ideation come later.
- ~~Flip pattern is secret~~ → reversed, see entry above.
- **Budget: as cheap as possible.** Shopping list switched to the cheapest parts (Uno R3-compatible kit, DIY IR pairs, MG996R + SG90 servos, plain LEDs). Borrow from Polimi labs first.
- **Fabrication:** Polimi has laser cutters and 3D printers; access procedure still to find out.

### 2026-10-07 · Scope (Danny)

- **Context only for now.** No code or hardware build yet; the repo holds the design and context. Code comes later in `arduino/` and `gui/`.

### 2026-10-07 · Initial design (Danny + Claude)

- **Game:** Connect Four with GUI, motors, single/multiplayer, cheater detection, scoring and a board flip. Assigned by the professors.
- **Board size: standard 7×6** (default). Easiest to buy and the standard computer-player techniques assume it.
- **Build on a bought Connect Four game** (default). Grid and coins are already precise; saves weeks.
- **GUI: ProtoPie + ProtoPie Connect** (from the course brief).
- **Arduino is the brain** (rules, AI, score); ProtoPie displays. One source of truth.
- ~~Microcontroller: Arduino Uno R4 Minima~~ → replaced by a cheap Uno R3-compatible board (see answers above).
- **Coin detection:** 7 IR break-beam sensors on a fixed bar above the columns. Colour comes from turn order; a colour sensor is optional.
- **Computer's coin is dropped by the human**; dropping it elsewhere = CHEAT (−1 point, coin stays, 3 cheats = loss).
- **Flip = 180° turn on a horizontal left-right axle** with a gate at each end. Each column keeps its coins in reverse order; columns don't swap. Chosen because it's the simplest mechanism that really "reverses the layout".
  - Considered: turning in the board's own plane (also mirrors columns left/right; needs a bigger, harder mechanism); flipping around a vertical axis (changes nothing for gravity, so no surprise lines).
- **Flip motor: one strong 180° servo** (MG996R on budget), not a stepper. A servo goes to an exact angle by itself; no extra sensors or driver.
- ~~Patterns: BOX, PYRAMID, DIAGONAL3~~ → BOX, T, L, FLAT L, ZIGZAG (see top). Must be one colour and include the new coin. Max 3 flips per game.
- **Winner after a flip:** most separate lines of 4+ wins; tie → the player who triggered the flip wins; no lines → keep playing.
  - Considered: tie = draw (anticlimactic at a demo); tie → the *other* player wins (makes flips purely a penalty); longest line wins (harder to explain).
- **Normal win beats flip** when one coin does both.
- **Scoring:** win +3, flip win +5, draw +1 each, cheat −1.
- **Message format:** `MESSAGE||VALUE` lines (ProtoPie Connect), table in `docs/04-software.md`.
