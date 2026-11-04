# Decisions log

Newest at the top. Each entry: date, decision, why, who. Marked **(default)** = picked by Claude to keep moving; the team can change it.

---

### 2026-11-04 · Flip or Skip, random pattern, flashing LEDs (Danny)

- **The system picks the pattern at random** at the start of each game (no player choice). The Arduino picks it and sends `PATTERN` to the app, which only shows it.
- **When the pattern is made, the player chooses Flip or Skip** on the app, which plays an animation; the **board's LEDs flash** at the same time. `FLIP||1` flips, `FLIP||0` skips. Replaces the reading below that the flip always happens.
- **Skip keeps the game's one flip available** (Claude's default): the next coin that completes the pattern offers the choice again. Change if the team prefers "skip = flip used up".
- **LEDs:** a WS2812B strip on D12, already in the pin plan, mounted on the fixed stand (not the turning board), so no pin or wiring change. See docs/03-hardware.md.

### 2026-11-04 · Two players + flip only (Danny, after talking to the professor)

- **Single player vs the computer is removed**: the computer player, suggested move, cheater detection and their messages (`SUGGEST`, `CHEAT`, `MODE`) are gone. Why: the professor said it is mostly coding and too complicated for our use case; the flip is the core of the project.
- **The flip starts with a Flip button on the app.** When the pattern is made the board closes its top, the app enables Flip, and the flipper presses it. Lights + beep warn for ~2 s before turning. New messages `FLIP_READY` (Arduino → app) and `FLIP` (app → Arduino). Answers the open question from 2026-10-27. ~~Our reading: the flip is not optional.~~ → Flip or Skip, see entry above.
- **Coin colour:** still from turn order; a per-column colour sensor is proposed as an upgrade (see below).
- **Hardware questions answered (proposal, not decided):** see `docs/03-hardware.md` → "Hardware questions answered". In short: 7 entry sensors are enough (no sensor per hole); an Uno has enough pins (14 of 18 used); sliding tab gates at both ends driven by MG90S + push rod; slow 180° turn with both gates closed; colour via green LED + phototransistor per column as an upgrade; **laser-cut our own grid (clear acrylic sandwich) and reuse the bought coins**, which would replace the 2026-10-07 default "build on a bought game". Waiting for the team.

### 2026-10-27 · Proposal, not decided: coin sensing and actuators (Claude, for the team)

- Options compared in `docs/03-hardware.md` → "Coin sensing and motion: options". Recommended: keep sensors on a **fixed entry bar** above the board (one set of 7 covers both orientations, since coins always enter from the top of the room), using **IR break-beams** (backup: TCRT5000 reflective modules); gates driven by **MG90S servos with printed rack-and-pinion** instead of real linear actuators; flip by a **270° high-torque servo** (or MG996R if its range is tested OK).
- Waiting for the team to pick. Until then the earlier defaults below still stand.

### 2026-10-27 · From the team chat (WhatsApp, 7–27 Oct)

- **New winner-after-flip rule (Danny, Airika agreed with the logic):** only the flipper has a line → flipper wins; only the other player → they win; **both → the player who did NOT flip wins**; nobody → play on with **no more flips**. Replaces "most lines wins, tie → flipper" and "max 3 flips". Why: a flip becomes a real risk you have to think through, and the rule is short for the demo.
- **After a flip the coins rearrange inside the board, they don't fall out.** The pull bars (gates) at both ends hold them. Same as before, now stated explicitly.
- ~~**Cheating ends the game**~~ and ~~**no difficulty levels**~~: single player was removed on 2026-11-04.
- **Presentation split (2026-10-17):** block diagram + strategy-fan persona = Danny, flow chart + solo-player persona = Yujia, storyboard = Airika, polish = anyone. Two personas, not three. See [docs/07-presentation.md](docs/07-presentation.md).
- ~~**Open:** automatic flip or player chooses?~~ → Flip button, see 2026-11-04.

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

- **Game:** Connect Four with GUI, motors, ~~single/~~multiplayer, ~~cheater detection,~~ scoring and a board flip. Assigned by the professors.
- **Board size: standard 7×6** (default). Easiest to buy and the standard computer-player techniques assume it.
- **Build on a bought Connect Four game** (default). Grid and coins are already precise; saves weeks.
- **GUI: ProtoPie + ProtoPie Connect** (from the course brief).
- **Arduino is the brain** (rules, AI, score); ProtoPie displays. One source of truth.
- ~~Microcontroller: Arduino Uno R4 Minima~~ → replaced by a cheap Uno R3-compatible board (see answers above).
- **Coin detection:** 7 IR break-beam sensors on a fixed bar above the columns. Colour comes from turn order; a colour sensor is optional.
- **Computer's coin is dropped by the human**; dropping it elsewhere = CHEAT ~~(−1 point, coin stays, 3 cheats = loss)~~ → cheating loses the game (see 2026-10-27).
- **Flip = 180° turn on a horizontal left-right axle** with a gate at each end. Each column keeps its coins in reverse order; columns don't swap. Chosen because it's the simplest mechanism that really "reverses the layout".
  - Considered: turning in the board's own plane (also mirrors columns left/right; needs a bigger, harder mechanism); flipping around a vertical axis (changes nothing for gravity, so no surprise lines).
- **Flip motor: one strong 180° servo** (MG996R on budget), not a stepper. A servo goes to an exact angle by itself; no extra sensors or driver.
- ~~Patterns: BOX, PYRAMID, DIAGONAL3~~ → BOX, T, L, FLAT L, ZIGZAG (see top). Must be one colour and include the new coin. ~~Max 3 flips per game~~ → one flip per game (see 2026-10-27).
- ~~**Winner after a flip:** most separate lines of 4+ wins; tie → the player who triggered the flip wins; no lines → keep playing.~~ → replaced, see 2026-10-27.
  - Considered: tie = draw (anticlimactic at a demo); tie → the *other* player wins (makes flips purely a penalty); longest line wins (harder to explain).
- **Normal win beats flip** when one coin does both.
- **Scoring:** win +3, flip win +5, draw +1 each, ~~cheat −1~~ (cheating now loses the game).
- **Message format:** `MESSAGE||VALUE` lines (ProtoPie Connect), table in `docs/04-software.md`.
