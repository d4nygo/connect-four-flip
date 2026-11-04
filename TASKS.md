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
- [ ] Hardware proposal (docs/03-hardware.md, "Hardware questions answered"): agree on sensors, gates, own laser-cut grid, colour sensing as an upgrade (4 Nov review)
- [ ] After a Skip, is the one flip used up? (default: no, raised 4 Nov)
- [ ] Add the professor's 4 Nov feedback to docs/08-timeline.md
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
