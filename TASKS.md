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
- [ ] Gates by hand or by servo?
- [ ] After a Skip, is the one flip used up? (default: no, raised 4 Nov)
- [ ] todo · Book the 3D-printer safety course (OpenLab) or contact the TED Laboratory (Bovisa)
- [ ] todo · Breadboard test: one Hall sensor (SS49E) on the ESP32 with a magnet in a coin, 50 drops
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
- [ ] todo · Buy remaining electronics: 4 × AA holder with switch + AAs, multi-core wire for the 9-wire bundle, maybe a servo extension (5 V adapter later) (docs/03-hardware.md → "Wiring: ESP32 DevKit V1")
- [ ] todo · ESP32 bench tests in order: Blink → measure battery rail → one A3144 on D23 (mark magnets' south face) → one column → all 7 → servo on battery rail
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

- [x] done (Claude, 2026-11-26) · ESP32 DevKit V1 pin check, pin plan and power plan for the parts we bought
- [x] done (Claude, 2026-11-26) · Wiring v3 (one breadboard side, no LEDs/buzzer) + 3D cable map with x-ray/exploded views
- [ ] todo · Confirm which ESP32 side is free on the breadboard (3V3…D23 expected); update the Tinkercad circuit to the v3 pins
- [ ] todo · Move cable routes onto the screw-free 3D model when it is ready

- [x] done (Claude, 2026-10-07) · Rules, flip and winner-after-flip rule designed; context docs and repo structure

## Lessons learned

_Add things that cost you time, so nobody repeats them._
