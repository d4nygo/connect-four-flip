# 04 · Software

## Who does what

```
 ┌──────────────┐   USB cable    ┌──────────────────┐   local network   ┌──────────────┐
 │   Arduino    │ ─────────────► │ ProtoPie Connect │ ────────────────► │ ProtoPie GUI │
 │ (the brain)  │ ◄───────────── │ (on the laptop)  │ ◄──────────────── │ (the screen) │
 └──────────────┘   serial text  └──────────────────┘                   └──────────────┘
```

- **Arduino = the brain and the referee.** It owns the board state, the rules, the computer player, cheater detection, the flip and the score. One source of truth means the screen can never disagree with the physical board.
- **ProtoPie = the face.** Menus (mode, difficulty, pattern), showing the grid, the computer's suggestion, the CHEATER screen, the flip animation, the winner and the scoreboard. It mostly reacts to messages.
- **ProtoPie Connect** (free desktop app from ProtoPie) passes messages between the Arduino's USB serial port and the ProtoPie prototype.

## Logic the code will need (plain-language spec)

No code yet. When the team starts coding, this is what the Arduino program must do, in this order:

1. **Board memory:** a 6×7 grid of numbers (0 empty, 1 red, 2 yellow), row 0 = bottom.
2. **Drop:** when column `c` gets a coin, find the lowest empty row and store the player there. Full column = error.
3. **Normal win check:** from the new coin, count matching coins in 4 directions (horizontal, vertical, two diagonals), looking both ways. 4 or more = win.
4. **Pattern check:** the Arduino picks the secret pattern at random at game start (and again after each flip). Does the new coin complete it (BOX / PYRAMID / DIAGONAL3) in its own colour? Try the new coin as each part of the shape.
5. **Flip:** for each column, reverse the order of its coins (the bottom one becomes the top one). Columns stay where they are.
6. **Winner after flip:** count each player's separate lines of 4+ on the whole board (a line of 5–7 counts once). More lines wins; equal → the flipper; none → keep playing.
7. **Computer move:** win if possible, else block, else (by level) random / prefer centre / look ahead a few moves (the "minimax" technique; ask your agent when you get there).
8. **Cheater check:** in single player, if the computer's coin lands in a column other than the one suggested → CHEAT.

Tip for later: write steps 1–6 so they can be tested on a laptop without hardware.

## Message protocol (Arduino ↔ ProtoPie)

ProtoPie Connect reads and writes **one line per message** in the form `MESSAGE||VALUE`. Verify this format against the ProtoPie Connect docs for the version you install, and update this table if it differs.

**Arduino → GUI**

| Message | Value | Meaning |
|---|---|---|
| `READY` | `1` | Arduino started |
| `STATE` | 42 digits, top row first, `0` empty, `1` red, `2` yellow | Full board, redraw the grid |
| `TURN` | `1` or `2` | Whose turn |
| `DROP` | `col,row,player` | A coin was detected |
| `SUGGEST` | `0`–`6` | Single player: the computer wants this column |
| `CHEAT` | `0`–`6` | Wrong column for the computer's coin → show CHEATER |
| `FLIP_START` | player who triggered | Start the flip animation |
| `PATTERN_REVEAL` | `0` box, `1` pyramid, `2` diagonal3 | Sent with `FLIP_START`: which secret pattern triggered |
| `FLIP_DONE` | 42 digits | Board after the flip |
| `WIN` / `FLIP_WIN` | `1` or `2` | Game over, normal win / win after a flip |
| `DRAW` | `1` | Board full |
| `SCORE` | `p1,p2` | Updated scores |
| `ERROR` | text | Something unexpected (e.g. `column_full`) |

**GUI → Arduino**

| Message | Value | Meaning |
|---|---|---|
| `MODE` | `SINGLE` / `MULTI` | Choose mode |
| `LEVEL` | `0` easy, `1` medium, `2` hard | Computer difficulty |
| `NEWGAME` | `1` | Release old coins and start |
| `RESET_SCORE` | `1` | Scores back to 0 |
| `SIMDROP` | `0`–`6` | **Testing:** pretend a coin was dropped, no sensors needed |

`SIMDROP` lets the GUI person build and test the entire game from the Arduino Serial Monitor or ProtoPie before the hardware exists.

## How the computer decides

1. If it can win right now, it plays there.
2. If you could win next move, it blocks you.
3. **Easy:** otherwise random. **Medium:** prefers the centre and avoids moves that let you win on top. **Hard:** imagines the next 5 moves for both sides (minimax with alpha-beta pruning) and scores positions by how many open 2s and 3s each side has.

It does not plan for flips. That is fine for a course demo and can be a stretch goal.

## Coin detection details

- A coin is counted the moment a beam goes from clear to blocked.
- After a coin, that column ignores the sensor for 400 ms (a coin can wobble through the beam twice). This delay will need tuning.
- If two coins come too fast or a sensor misfires, `ERROR` messages show up; the GUI can show a "please wait" state.

## GUI screens to design in ProtoPie

1. Home: Single player / Multiplayer
2. Setup: difficulty (single only), the list of possible flip patterns with a "???" for the secret one, Start
3. Game: 7×6 grid mirroring `STATE`, whose turn, the computer's suggested column, scoreboard, flip counter
4. CHEATER overlay (big, red, funny)
5. Flip animation (triggered by `FLIP_START`, ended by `FLIP_DONE`)
6. Game over: winner, how they won (normal or flip), points earned, Play again
