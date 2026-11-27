# Decisions log

Newest at the top. Each entry: date, decision, why, who. Marked **(default)** = picked by Claude to keep moving; the team can change it.

---

### 2026-11-27 · Print plan: 5 runs (Danny asked for the fewest print runs)

- **All 60 pieces in 5 runs** on a 220 × 220 mm bed, plus a 2 h sensor test piece first: run 1 board half + 2 foot sockets, run 2 board half + 2 gates, run 3 left upright + 21 red coins, run 4 right upright + 21 yellow coins, run 5 sensor bar + tray + clips, straps, pins (spares included). About 48.5 h and 491 g PLA. 5 is the minimum: each board half and each upright fills a bed, and the bar (219 mm) fits beside none of them.
- **(default) Uprights printed in red (left) and yellow (right)**, because the coins ride along in their corners. One run = one colour.
- **(default) Clips and servo strap in PLA** on run 5 with spares; PETG only if they crack (replaces the earlier PETG default).
- Per-object infill: big parts 20 % gyroid, coins/gates/clips/strap/pins 100 %; lock pins get a 3 mm brim; no skirt. Plate files (3MF) are in the project files, not in git.
- Design review file for the professors (single self-contained HTML) made for approval to build.

### 2026-11-27 · Fit check fixes (Danny asked for a clearance and cable audit)

- **(default) Uprights 10 mm thick** (was 8) so the cable channels can be 5 mm deep; servo side geometry unchanged.
- **(default) Thrust ring on the right upright**: board side play 0.8 mm, so the horn can't walk out of its pocket.
- **(default) 26–28 AWG stranded wire** recommended for the sensor rows and bundle (jumper wires fit but fill channels ~50%).
- **(default) Print clips and servo strap in PETG** if available.

### 2026-11-26 · Screw-free stand (Danny)

- **No screws anywhere** (Danny). Pegs + snap clips for the board halves, a snap strap for the servo, glued foot sockets for the uprights, a push-in axle pin, drop-in sensor bar with lock pins.
- Sensors read "3144" (digital switch, Danny checked). The servo horn is in the bag.
- **(default) Sensor rows are soldered on the table as strips** (bus wires for 5 V and GND, one OUT wire each), then pressed into the bar; front and back OUT wires are joined outside the right upright.
- ESP32 plugs straight into the breadboard (wiring thread / Danny); the printed holder is dropped.

### 2026-11-26 · Model matched to the parts we bought

- **(default) ESP32 on a printed holder with 18 mm posts, beside the breadboard,** not plugged into it: the 30-pin DevKit covers every hole on one side of an 830-point breadboard.
- **(default) Base board grows to 300 × 205 mm,** electronics at the back, outside the board's sweep.
- **(default) Servo flange holes slotted** for 48.5 to 49.5 mm spacing.
- **Open:** the sensor bag says "A3144 Linearer". The A3144 is an on/off switch; a linear sensor (49E) gives an analog voltage and changes the wiring. Read the marking on one sensor.

### 2026-11-26 · Gates slide side to side (Danny)

- **Gates slide sideways like the shop game's slider** (slotted ladder strip), not front to back. Why (Danny): a front-to-back gate could slide open by gravity while the board turns; a sideways gate moves along the flip axle, where gravity never pulls.
- **(default) Servo horn drops into a horn-shaped pocket** in the board, no screws (they can't be reached once assembled).
- **Leave cable channels in the model** (Danny): along the sensor bar and down both uprights.
- **Open:** 14 sensors (2 per column, one magnet per coin) or 7 sensors with 2 magnets per coin (needs ~84 magnets). Waiting for the team.

### 2026-11-24 · 3D-printable stand, concept v0 (Claude, proposal for the team)

- **(default) Printed 24 mm coins**, board ~215 × 171 mm, all parts within a 220 mm print bed. Why: Danny asked for a board smaller than the standard game, cheap and quick to print. Shop coins (~33 mm) would need a bigger board split into pieces.
- **(default) Two A3144 sensors per column** (front and back wall), wired together, one magnet per coin. Why: the A3144 only sees the south pole and a coin can be inserted either way round.
- **(default) Gates by hand:** sliding plate, centred = closed with a magnet click, push either way to open. Keeps the turning board wire-free. Answers "gates by hand or servo" unless the team objects.
- **(default) Flip servo drives the board directly** (horn on the board's boss), printed pivot pin on the other side; axle through the middle of the coin slots.
- Details in `docs/03-hardware.md` → "3D-printable stand, concept v0". Untested on hardware.

### 2026-11-18 · Review: ESP32 instead of Arduino (professor)

- **Use an ESP32-based board, not an Arduino Mega**, so it can read up to 8 analog values (7 analog Hall sensors). Replaces the Arduino Uno default. Suggested board: ESP32-S3 DevKit (10 analog pins on its first converter). It runs on 3.3 V; see `docs/03-hardware.md` → "Professor's feedback (4 and 18 Nov)" for the pin plan. Untested on hardware.

### 2026-11-04 · Review: hardware approach approved (professor)

- **The hardware proposal was approved**: 7 fixed sensors at the top, board turning underneath, gravity gives the row. Next: final components list and get the parts.
- **Sensors (professor's suggestion):** **magnets inside the coins** with **Hall sensors** (more precise) or **reed sensors**, instead of light beams. Colour still comes from turn order (a coin can be dropped either way round, which flips the magnet's pole).
- **Team leaning, not decided:** gates opened and closed **by hand** (Airika). 3D printing at Polimi OpenLab (safety course) or TED Laboratory (Bovisa).

### 2026-11-04 · Flip or Skip, random pattern, flashing LEDs (Danny)

- **The system picks the pattern at random** at the start of each game (no player choice). The Arduino picks it and sends `PATTERN` to the app, which only shows it.
- **When the pattern is made, the player chooses Flip or Skip** on the app, which plays an animation; the **board's LEDs flash** at the same time. `FLIP||1` flips, `FLIP||0` skips. Replaces the reading below that the flip always happens.
- **Skip keeps the game's one flip available** (Claude's default): the next coin that completes the pattern offers the choice again. Change if the team prefers "skip = flip used up".
- **LEDs:** a WS2812B strip on D12, already in the pin plan, mounted on the fixed stand (not the turning board), so no pin or wiring change. See docs/03-hardware.md.

### 2026-10-28 · Class review: two players + flip only (professor; logged 2026-11-04)

- **Single player vs the computer is removed**: the computer player, suggested move, cheater detection and their messages (`SUGGEST`, `CHEAT`, `MODE`) are gone. Why: the professor said it is mostly coding and too complicated for our use case; the flip is the core of the project.
- **Professor's hardware feedback:** go ahead with the rotating version; detect coins with light / infrared presence sensors; keep 7 fixed sensors and rotate the board underneath them. This matches the fixed entry bar proposal.
- **New game flow (from the class):** pattern set before the game, live coin positions in the app, Flip button enabled when the pattern is made, board flips, app shows the new positions and the winner/condition.
- **The flip starts with a Flip button on the app.** When the pattern is made the board closes its top, the app enables Flip, and the flipper presses it. Lights + beep warn for ~2 s before turning. New messages `FLIP_READY` (Arduino → app) and `FLIP` (app → Arduino). Answers the open question from 2026-10-27. ~~Our reading: the flip is not optional.~~ → Flip or Skip, see entry above.
- **Coin colour:** still from turn order; a per-column colour sensor is proposed as an upgrade (see below).
- **Hardware doubts raised in class**, answered as a proposal for the 4 Nov review: see `docs/03-hardware.md` → "Hardware questions answered". In short: 7 entry sensors are enough (no sensor per hole); an Uno has enough pins (14 of 18 used); sliding tab gates at both ends driven by MG90S + push rod; slow 180° turn with both gates closed; colour via green LED + phototransistor per column as an upgrade; **laser-cut our own grid (clear acrylic sandwich) and reuse the bought coins**, which would replace the 2026-10-07 default "build on a bought game". Waiting for the team.

### 2026-10-27 · Phone app instead of laptop (Danny)

- **The players use a phone app** (ProtoPie) as the screen, not a laptop.
- **Prototype (default):** ProtoPie Player on the phone, connected over Wi-Fi to ProtoPie Connect on a hidden PC, which talks to the Arduino by USB. Why: as far as we know ProtoPie can't reach Bluetooth or the Arduino directly, and the course template's own example does it this way.
- **Final-product idea:** a Bluetooth module on the board (HM-10 BLE works with iPhone and Android; HC-05 is Android only). Same `MESSAGE||VALUE` messages.
- Open: ask the professor whether a phone-only setup (no PC) is possible with ProtoPie.

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
- **GUI: ProtoPie + ProtoPie Connect** (from the course brief). Screen is now a phone, see 2026-10-27.
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
