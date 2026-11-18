# 08 · Project timeline and open questions

The dated story of the project: what happened at each class, review or team discussion, and the questions raised there. Newest decisions live in [DECISIONS.md](../DECISIONS.md); this file shows **when** and **where** things came up. The same timeline is kept as stickies on the "some-information" FigJam board (see "Where things live" below).

Add each new review or discussion as a new section at the bottom. When an open question is answered, record the answer under the new date and strike it through where it was raised.

## 3–4 Oct 2026 · Brief and game choice

- **Brief:** remake a classic board game as a physical board run by an Arduino, plus a companion app made in ProtoPie, with two-way communication (board → app: what happened; app → board: what to do). Keep the original mechanics; the digital part adds enhancements. None of us has experience with electronics, mechanics or programming. See [01-brief.md](01-brief.md).
- **Team discussion, which game?** Compared Four in a Row, Horse Racing, Game of the Goose and Operation. Difficulty estimate: Operation 2/5 (up to 4/5), Four in a Row 3/5, Horse Racing 4/5 (2/5 with LEDs). Four in a Row needs only 7 sensors to track the whole grid; the challenge is making the digital part feel essential. Comparison: [archive/game-comparison.md](archive/game-comparison.md).

## 7 Oct 2026 · Connect Four Flip assigned

- **Professors' assignment:** Connect Four with a GUI and motorised elements. Single player vs computer (detect the coin, the computer shows its move, "CHEATER!" warning, scoring), multiplayer, and a whole-board flip when a pattern chosen at game start is made, with a rule for the winner after a flip.
- **Decided:** standard 7 × 6 board, red = P1 and starts; flip pattern visible all game; patterns are exactly 4 coins, never a straight line (BOX, T, L, FLAT L, ZIGZAG; mirror counts, rotation doesn't); normal win beats a flip; scoring win +3, flip win +5, draw +1.
- **Decided, the flip:** 180° turn on a horizontal left-right axle; each column keeps its coins in reverse order; the Arduino computes the new grid.
- **First hardware concept:** build on a bought game, 7 IR break-beams on a fixed bar, one strong servo for the flip, a gate at each end, Uno-compatible board, external 5 V for servos, cheapest parts, Polimi laser cutters and 3D printers.
- **Software architecture:** the Arduino is the brain (state, rules, score); the ProtoPie app displays and sends choices; `MESSAGE||VALUE` lines through ProtoPie Connect.
- **Way of working:** this GitHub repo holds rules, decisions and tasks for all three of us. Design and documentation first, building later; no code yet (Danny).
- **Open questions raised:**
  - [ ] Final deadline and the dates of later reviews
  - [ ] Is there a ProtoPie licence for students?
  - [ ] How do we book the Polimi laser cutters and 3D printers, and can we borrow Arduinos, servos and power supplies?
  - [x] ~~Final split of roles~~ → see 4 Nov

## 27 Oct 2026 · Team rules and EX2 preparation

- **Decided in team discussion (WhatsApp, 7–27 Oct):** one flip per game; after a flip, only one player has a line of 4+ → they win; both → the player who did NOT flip wins; nobody → play on, no more flips. No difficulty levels. (Cheating rules dropped later with single player.)
- **EX2 presentation (28 Oct, 3 min):** slide 3 personas (Marco Ferri, 27, the strategy seeker by Danny; a solo player by Yujia), slide 4 storyboard (Airika), slide 5 flow chart (Yujia), slide 6 block diagram (Danny). See [07-presentation.md](07-presentation.md).
- **Decided, phone app:** the app runs on a phone, not a laptop. Prototype: phone (ProtoPie Player, Wi-Fi) → ProtoPie Connect on a hidden PC → USB → Arduino. Final-product idea: a Bluetooth module on the board (HM-10 BLE for iPhone + Android, HC-05 Android only). See [04-software.md](04-software.md).
- **Proposed, sensing and motors:** one fixed sensor bar above the board, so the same 7 sensors work in both orientations; IR break-beams (TCRT5000 as cheaper backup); small servos for the gates instead of linear actuators; a 270° high-torque servo (or MG996R) for the flip. See [03-hardware.md](03-hardware.md).
- **Open questions raised:**
  - [ ] Final choice of sensors and motors → proposal ready for 4 Nov
  - [x] ~~How do we warn players not to drop coins during the flip (lights on the board?)~~ → board LEDs flash + top gate closes, see 4 Nov
  - [ ] Can the phone talk to the Arduino without a PC in between?

## 28 Oct 2026 · Class review: scope cut and new flow

- **Professor's feedback:** go ahead with the rotating version. Detect the pieces with light or infrared presence sensors. Keep 7 fixed sensors and rotate the board underneath them.
- **Scope cut:** single player vs computer is removed (too code-heavy). No computer opponent, suggested move or cheater detection. The project is the flip mechanism in multiplayer.
- **New game flow:** flip pattern set before the game; the board tracks coin positions in real time; when the pattern is made, the app enables a Flip button; Flip sends the command and the board flips; the app shows the new positions and the winner (if any) and the condition that decided it.
- **Open questions raised (the team's hardware doubts):**
  - [x] ~~Can players skip the flip, or must they press Flip?~~ → Flip or Skip, see 4 Nov
  - [ ] How do we detect the coin positions, and do we need that many sensors? → proposal: 7 entry sensors
  - [ ] Can the Arduino handle all the sensors? → proposal: Uno, 14 of 18 pins
  - [ ] How do the bottom and top gates open and close, and what happens during the flip? → proposal: sliding tab strips + servo, both closed during the turn
  - [ ] How do we detect which colour coin is inserted? → proposal: turn order; green LED + light sensor as upgrade
  - [ ] Which material and model should we build with? → proposal: laser-cut clear acrylic grid, bought coins

  The proposed answers are in [03-hardware.md](03-hardware.md) → "Hardware questions answered", to discuss at the 4 Nov review.

## 4 Nov 2026 · Review (proposed hardware)

- **Team discussion, who does what:** Airika: UI design of the app (flows and interactions). Danny: review presentation, research on the Arduino side, keeping the FigJam up to date. Yujia (Jessica): possible 3D models and research on the servos needed.
- **Decided (Danny), random pattern + Flip or Skip:** the system picks the flip pattern at random at the start of each game. When the pattern is made, the app enables Flip with an animation, the board's LEDs flash, and the player chooses **Flip** or **Skip**.
- **To discuss with the professor:** the proposed hardware approach (7 fixed sensors, Uno pin budget, sliding gates, flip sequence, colour by turn order, laser-cut grid, LED strip).
- **Professor's feedback:** _to add after the review._
- **Open questions raised:**
  - [ ] After a **Skip**, is the game's one flip used up, or can the next pattern offer it again? (Current default: still available.)

## All open questions in one place

| Question | Raised | Status |
|---|---|---|
| Final deadline and later review dates | 7 Oct | open |
| ProtoPie licence for students | 7 Oct | open, ask the professor |
| Booking Polimi laser cutters / 3D printers; borrowing Arduinos, servos, power supplies | 7 Oct | open |
| Final choice of sensors and motors | 27 Oct | proposal ready, to agree at/after 4 Nov |
| Phone talking to the Arduino without a PC | 27 Oct | open, ask the professor |
| Coin positions, sensor count, pins, gates, colour, materials | 28 Oct | proposal ready (03-hardware.md), to agree |
| Does Skip use up the one flip? | 4 Nov | open (default: no) |

## Where things live

| What | Where | Who edits |
|---|---|---|
| Rules, decisions, tasks, hardware and software notes (the team's memory bank) | this repo | everyone, via pull requests |
| Course "second brain" board with the professor's frames and review notes | FigJam **Group-06**: https://www.figma.com/board/cFqNQgyYD09Ue6Vv8wCWOq/Group-06 | **Danny only** |
| Team working board: concept, flow chart, storyboard, coin-sensing section, and the editable project timeline (section "Project timeline") | FigJam **some-information**: https://www.figma.com/board/VZNR8pWM3hTzOPEdv5kL9L/some-information | the team; AI agents edit only this board |
| EX2 slides (professor's template) | Figma Slides: https://www.figma.com/slides/k9LasGtEKIIYfWlgTlsmq8 | the team |
| Hardware answers as a readable page | Danny's Claude artifact "Flip Board Hardware" (private, shared by Danny) | Danny's Claude |

Both FigJam boards are shared with the professors: write them in the team's voice (discussions, decisions, open questions), with no mention of AI tools, threads or pull requests.
