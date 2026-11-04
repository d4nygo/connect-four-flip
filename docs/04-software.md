# 04 · Software

## Who does what

```
 ┌──────────────┐   USB cable    ┌──────────────────┐   local network   ┌──────────────┐
 │   Arduino    │ ─────────────► │ ProtoPie Connect │ ────────────────► │ ProtoPie GUI │
 │ (the brain)  │ ◄───────────── │ (on the laptop)  │ ◄──────────────── │ (the screen) │
 └──────────────┘   serial text  └──────────────────┘                   └──────────────┘
```

- **Arduino = the brain and the referee.** It owns the board state, the rules, the pattern check, the flip and the score. One source of truth means the screen can never disagree with the physical board.
- **ProtoPie = the face.** Pattern choice, showing the grid live, whose turn, the Flip button, the flip animation, the winner and the scoreboard. It mostly reacts to messages.
- **ProtoPie Connect** (free desktop app from ProtoPie) passes messages between the Arduino's USB serial port and the ProtoPie prototype.

## Logic the code will need (plain-language spec)

No code yet. When the team starts coding, this is what the Arduino program must do, in this order:

1. **Board memory:** a 6×7 grid of numbers (0 empty, 1 red, 2 yellow), row 0 = bottom.
2. **Drop:** when column `c` gets a coin, find the lowest empty row and store the player there. Full column = error.
3. **Normal win check:** from the new coin, count matching coins in 4 directions (horizontal, vertical, two diagonals), looking both ways. 4 or more = win.
4. **Pattern check:** does the new coin complete the chosen pattern (BOX / T / L / FLAT L / ZIGZAG, as drawn or left-right mirrored, never rotated) in its own colour? Simplest method: store each shape and its mirror as a list of 4 positions, and try the new coin as each of the 4 coins of each version.
5. **Flip:** for each column, reverse the order of its coins (the bottom one becomes the top one). Columns stay where they are.
6. **Winner after flip:** check whether each player has at least one line of 4+ on the whole board. Only one has a line → they win; both → the player who did NOT flip wins; none → keep playing, and no more flips this game.
7. **Flip control:** when the pattern is made, close the top gate, send `FLIP_READY`, ignore the sensors, and wait for `FLIP` from the app. Then warn (lights + beep), turn slowly, wait for the coins to settle, open the new top gate, send `FLIP_DONE` and the result.

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
| `FLIP_READY` | player who made the pattern | Pattern made: enable the Flip button |
| `FLIP_START` | player who triggered | Start the flip animation |
| `FLIP_DONE` | 42 digits | Board after the flip |
| `WIN` / `FLIP_WIN` | `1` or `2` | Game over, normal win / win after a flip |
| `DRAW` | `1` | Board full |
| `SCORE` | `p1,p2` | Updated scores |
| `ERROR` | text | Something unexpected (e.g. `column_full`) |

**GUI → Arduino**

| Message | Value | Meaning |
|---|---|---|
| `PATTERN` | `0` box, `1` T, `2` L, `3` flat L, `4` zigzag | Chosen flip pattern (the GUI picks one at random for "Random") |
| `FLIP` | `1` | The Flip button was pressed: start turning the board |
| `NEWGAME` | `1` | Release old coins and start |
| `RESET_SCORE` | `1` | Scores back to 0 |
| `SIMDROP` | `0`–`6` | **Testing:** pretend a coin was dropped, no sensors needed |

`SIMDROP` lets the GUI person build and test the entire game from the Arduino Serial Monitor or ProtoPie before the hardware exists.

## Coin detection details

- A coin is counted the moment a beam goes from clear to blocked.
- After a coin, that column ignores the sensor for 400 ms (a coin can wobble through the beam twice). This delay will need tuning.
- If two coins come too fast or a sensor misfires, `ERROR` messages show up; the GUI can show a "please wait" state.

## GUI screens to design in ProtoPie

1. Setup: flip pattern (pictures of the 5 shapes + Random), Start
2. Game: 7×6 grid mirroring `STATE` live, the chosen pattern always visible, whose turn (big, in that colour), scoreboard
3. Flip button: hidden or greyed out until `FLIP_READY`, then big and pulsing; pressing it sends `FLIP||1`
4. Flip animation (triggered by `FLIP_START`, ended by `FLIP_DONE` with the new grid)
5. Game over: winner, how they won (normal, or after the flip and why), points earned, Play again
