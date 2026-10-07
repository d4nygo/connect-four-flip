# 05 · Learning path (zero experience → working board)

You don't need to learn "programming" in general. You need a small, specific set of skills. Use your Claude agent as a tutor: paste errors, ask "explain this line", ask it to draw wiring.

Free tools to start **today, before buying anything**:

- **Wokwi** (wokwi.com): an Arduino simulator in the browser with LEDs, servos, buttons and NeoPixels. Later you can test the game code there with buttons instead of IR sensors.
- **Tinkercad Circuits** (tinkercad.com): drag-and-drop circuits plus beginner lessons.
- **Arduino IDE 2** (arduino.cc): the app that uploads code to the real board.
- **ProtoPie** + **ProtoPie Connect**: check your student licence.

## Stage 1 · Everyone (first week)

1. Install Arduino IDE. Upload the built-in example *Blink*. (You just programmed hardware.)
2. Do the official Arduino *Getting Started* lessons on digital output, digital input (a button), and the Serial Monitor.
3. Read `docs/02-game-rules.md` until you can explain the flip rule to someone.

## Stage 2 · Split by role

**Hardware / mechanics**
- Wire one IR break-beam, print its state to the Serial Monitor, drop coins through it.
- Wire one MG90S servo with an external supply (common ground!) and sweep it (example *Servo > Sweep*).
- Sketch the stand on paper with real measurements of the bought game, then in cardboard, then wood/acrylic.

**Arduino code**
- Learn the basics the game needs: variables, `if`, loops, arrays (the board is a 6×7 array), functions, and sending text over Serial.
- Ask your agent to explain the "Logic the code will need" section of `docs/04-software.md` in plain words.
- When code starts: build a `SIMDROP||3` test message first, so the game can be played from the Serial Monitor without any sensors.

**GUI / ProtoPie**
- ProtoPie basics: scenes, variables, triggers, "Receive" and "Send" responses.
- Connect ProtoPie Connect to the Arduino and make one rectangle change colour on `DROP`.
- Build the screens listed in `docs/04-software.md`.

## Stage 3 · Integration milestones

| # | Milestone | Proof |
|---|---|---|
| M1 | 7 sensors report the right column every time | 50 drops, 0 mistakes |
| M2 | Multiplayer game playable with the GUI showing the grid | Full game recorded |
| M3 | Single player: computer suggests, CHEATER works, score updates | Demo video |
| M4 | Gates hold coins upside down (by hand, no motor) | Photo/video |
| M5 | Motorised flip + correct grid on the GUI afterwards | Demo video |
| M6 | Polished: sounds, animations, enclosure, presentation | Final demo |

Always keep a working version. Build M2 completely before attempting the flip; if the flip is late, you still have a game.
