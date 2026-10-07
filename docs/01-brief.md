# 01 · The brief

Course: **Hardware and Software Technologies for Design**. Team of 3. Nobody on the team has prior experience with mechanics, electronics or programming, so every doc in this repo is written for beginners.

## What the course asks for

Remake a classic board game as a **physical board driven by an Arduino**, plus a **digital companion app (GUI) made in ProtoPie**, with **two-way communication**:

- board → app: the board tells the app what happened (a coin was dropped, where, who won)
- app → board: the app tells the board what to do (start a game, light a column, flip)

The original mechanics must stay; the digital part adds enhancements.

## What the professors assigned us (2026-10-07)

**Connect Four, "but a bit more complicated":**

1. **GUI + motorised elements.**
2. **Choose single player or multiplayer** at the start.
3. **Single player vs the computer:**
   - the Arduino detects which column the player drops a coin into
   - the computer shows on the GUI which column it wants to play
   - the player drops the computer's coin there for it
   - if the coin goes somewhere else, the GUI shows **"CHEATER!"**
   - the computer keeps track of the **score**
4. **The flip mechanic** (in both single and multiplayer):
   - at the start of the game a **pattern** is chosen
   - the board watches the coin positions; when someone makes that pattern, **the whole board physically flips**, reversing the layout
   - after a flip, new rows of 4 may appear, possibly for both players at once, so there must be a **rule for who wins**

## How we read the open points

| Question | Our reading |
|---|---|
| "Detect which coin the user is putting in" | Detect **which column** the coin goes into. The colour is known from whose turn it is. A colour sensor is an optional upgrade. |
| Who drops the computer's coin? | The human, into the column the GUI shows. That is what makes cheating possible. |
| "Flip completely reversing the layout" | The board turns 180° on a horizontal axle; coins slide to the new bottom, so each column's order is reversed. See [02-game-rules.md](02-game-rules.md). |

Original assignment screenshots: [assignment-1.png](assets/assignment-1.png), [assignment-2.png](assets/assignment-2.png). Earlier game comparison: see `docs/archive/game-comparison.md`.
