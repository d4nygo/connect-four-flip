# Tasks

Status: `todo` · `doing (name)` · `done (name, date)` · `blocked (why)`. Put your name on a task before starting.

## Roles (suggested, swap freely)

| Role | Owns | Who |
|---|---|---|
| Hardware & mechanics | stand, axle, gates, sensor bar, wiring, `docs/03-hardware.md` | Yujia (3D models, servo research) |
| Arduino code | `arduino/` (later), `docs/04-software.md` (code part) | Danny (Arduino research) |
| GUI & experience | ProtoPie app UI, flows and interactions, `docs/04-software.md` (GUI part) | Airika |
| Presentation & boards | review presentation, FigJam timeline | Danny |

Team: Danny George Oommen (`d4nygo`), Airika Jaldybayeva (`rikosyaa`), Yujia Ren (`Gilgamesh-Plan`). Roles from the team discussion of 4 Nov 2026; swap freely.

Everyone owns `docs/02-game-rules.md` together: rule changes are agreed by all three.

## Open questions (answer and move to DECISIONS.md)

- [ ] Final deadline date and later review dates (known: EX2 presentation on 2026-10-28, 3 minutes)
- [ ] ProtoPie licence: no student plan found; ask the professor
- [ ] Phone app: can ProtoPie on a phone talk to the Arduino without a PC (Bluetooth)? Ask the professor
- [ ] Polimi lab access: how to book laser cutter / 3D printer, and can we borrow Arduinos, servos, power supplies?
- [x] Hardware approach approved by the professor (4 Nov); ESP32 instead of Arduino (18 Nov)
- [ ] Final components list (professor, 4 Nov): Hall or reed sensors + magnets, ESP32 board, flip motor, gates by hand or servo
- [ ] Gates by hand or by servo? (proposal 24 Nov: by hand, sliding plate with magnet click; team to confirm)
- [ ] After a Skip, is the one flip used up? (default: no, raised 4 Nov)
- [ ] todo · Book the 3D-printer safety course (OpenLab) or contact the TED Laboratory (Bovisa)
- [ ] todo · Breadboard test: one A3144 on the ESP32 with a magnet in a printed coin through `sensor_test`, 50 drops each way round
- [ ] todo · Check the bought parts: horn in the servo bag? sensor marking 3144 or 49E? ESP32 hole spacing (`esp_*` in the model)
- [ ] todo · Measure the servo (flange to horn face) and its real 0°/180° pulse values; update `cad/flip_board.scad`
- [ ] todo · Team OK on printed 24 mm coins (concept v0, 24 Nov)
- [ ] todo · Send the design review file (`docs/design-review/flip-board-design-review.html`) to the professor for build approval (Danny)
- [x] App prototype (Danny): pattern chosen before the game, Flip or Skip when it's made (`gui/Play_FLIP.html`, 27 Nov)
- [ ] Uprights in red and yellow (saves 2 print runs) or grey (7 runs)? (Danny to confirm)
- [x] Print plan: 5 runs + sensor test, plate 3MFs in project files `flip-board-cad/print-runs/` (Claude for Danny, 2026-11-27)
- [x] Mechanical concept v0 + parametric model (`cad/flip_board.scad`) (Claude for Danny, 2026-11-24)
- [x] Pattern made → board LEDs flash, app shows Flip or Skip; pattern picked at random by the system (Danny, 2026-11-04)
- [x] Single player removed; two players + flip only (professor, class review 2026-10-28)
- [x] Board size: standard 7×6 (Danny)
- [x] GUI: ProtoPie (Danny)
- [x] Budget: as cheap as possible (Danny)
- [x] Flip pattern: visible, 4 coins, not a straight line, exact shape (mirror OK, no rotation) (Danny)

## EX2 presentation (due 2026-10-28, see docs/07-presentation.md)

- [x] done (Danny, 2026-10-27) · Block diagram on slide 6
- [x] done (Danny, 2026-10-27) · Persona "Marco, the strategy seeker" on slide 3
- [ ] doing (Yujia) · Solo-player persona on slide 3
- [ ] doing (Yujia) · Flow chart on slide 5
- [ ] doing (Airika) · Storyboard on slide 4, title and description style
- [ ] todo · Polish all slides in one style

## Stage 1 · Setup and learning

- [x] done (Danny, 2026-10-07) · Added `rikosyaa` and `Gilgamesh-Plan` as collaborators
- [ ] todo · Ask Polimi labs / course staff about borrowing parts and fab access
- [ ] todo · Everyone: Arduino IDE installed, Blink uploaded
- [ ] todo · Everyone: read docs/02-game-rules.md
- [ ] todo · Buy the Connect Four game and parts (docs/03-hardware.md)
- [ ] todo · Measure the coins (diameter, thickness) and the column pitch; they size the grid and gates
- [ ] todo · Breadboard test: one IR beam, and one green LED + phototransistor with red vs yellow coins
- [ ] todo · Code: Wokwi tutorials (button + LED + servo in the simulator)
- [ ] todo · GUI: phone (ProtoPie Player) ↔ ProtoPie Connect ↔ Arduino (one `DROP` message works)

## Stage 2 · Milestones (see docs/05-learning-path.md)

- [ ] todo · M1 sensors reliable (50 drops, 0 mistakes)
- [ ] todo · M2 multiplayer playable with the GUI
- [ ] todo · M3 pattern detected → Flip button, score
- [ ] todo · M4 gates hold coins upside down
- [ ] todo · M5 motorised flip + correct grid after
- [ ] todo · M6 polish and presentation

## Done

- [x] done (Claude, 2026-10-07) · Rules, flip and winner-after-flip rule designed; context docs and repo structure

## Lessons learned

_Add things that cost you time, so nobody repeats them._
