# 02 · Game rules (the official rulebook for our version)

This is the single source of truth for rules. Any code written later must implement exactly this. If you change a rule, log it in [DECISIONS.md](../DECISIONS.md).

## Board

- Standard Connect Four: **7 columns × 6 rows**, 42 coins (21 red, 21 yellow).
- Red = **Player 1** (the human in single player). Yellow = **Player 2** (the computer in single player).
- Red always starts.

## Game setup (on the GUI)

1. Choose **Single player** or **Multiplayer**.
2. Single player only: choose difficulty (**Easy / Medium / Hard**).
3. Choose the **flip pattern** (or press "Random"). It stays **visible on screen for the whole game**, so everyone knows what to aim for.
4. Press **Start**. The board drops any old coins out of the bottom and closes.

## A normal turn

1. The player drops a coin into a column.
2. The sensor above that column detects it. Gravity decides the row, so the Arduino always knows the full grid.
3. The Arduino checks, **in this order**:
   1. **Normal win**: did this coin make 4 in a row (horizontal, vertical, diagonal)? → that player wins. Game over.
   2. **Draw**: is the board full? → draw.
   3. **Pattern**: did this coin complete the flip pattern **in the dropping player's own colour**? → **FLIP** (see below).
   4. Otherwise, it is the other player's turn.

A normal win beats a flip: if one coin makes both 4-in-a-row and the pattern, the player simply wins.

## Single player: computer turns and cheating

1. After your move, the computer picks a column and shows it on the GUI (and lights the LED above that column).
2. **You drop the yellow coin into that column for the computer.**
3. If the coin lands in **a different column**:
   - the GUI shows **"CHEATER!"**, the board flashes red and buzzes
   - you lose **1 point**
   - the coin stays where it fell (the board must always match reality; we can't pull coins back out)
   - **3 cheats in one game = you lose that game automatically**

## The flip

### Patterns to choose from

Every pattern is made of **exactly 4 coins** and is **never a straight line** (a straight line of 4 is already a normal win). The shape must match **exactly as drawn**, the right way up. A **left-right mirror image also counts**, but a turned or upside-down version does not. It must be made of **one player's colour only** and must include the coin that was just dropped.

| Name | Shape | Feel |
|---|---|---|
| **BOX** | 2×2 square | Medium, the default |
| **T** | three in a row with one sticking out from the middle | Medium |
| **L** | a column of three with one to the side at the bottom | Medium |
| **FLAT L** | a row of three with one on top at an end | Easier |
| **ZIGZAG** | two pairs side by side, shifted by one | Harder |

```
BOX       T           L         FLAT L      ZIGZAG
X X       X X X       X .       X . .       . X X
X X       . X .       X .       X X X       X X .
                      X X
```

**Mirrors count, turns don't.** For example, the mirrored L (`. X / . X / X X`) and the mirrored ZIGZAG (`X X . / . X X`) both trigger the flip. An upside-down T or an upside-down L does not.

Limits: at most **3 flips per game**. An old pattern can't trigger again; only a new coin that completes one does.

**Always visible:** the chosen pattern stays on screen for the whole game, so both players know what to build and what to block. Setting up the pattern on purpose is part of the strategy.

### What physically happens

The board is mounted on a **horizontal axle** running left to right through its middle. The motor turns it **180°** (top goes over to the front and down to the bottom). Before turning, a gate closes the open top so no coins fall out. After turning, the coins slide down to the new bottom, and the gate on the end that is now on top opens so play can continue.

Effect on the grid: **each column keeps its coins, but their order is reversed** (the top coin of each stack becomes the bottom coin). Columns do **not** swap left and right. Shorter columns change the most, because their coins move down past empty space; this is where surprise lines appear.

Example (only the bottom three rows shown, columns left to right):

```
Before flip               After flip
row 2:  R R R . . . .     row 2:  Y Y R . . . .
row 1:  Y Y Y R . . .     row 1:  Y Y Y Y . . .   <- yellow line!
row 0:  Y Y R Y . . .     row 0:  R R R R . . .   <- red line!
```

Column 0 read Y,Y,R from the bottom up and now reads R,Y,Y; column 3 read Y,R and now reads R,Y. Nobody had four before the flip; afterwards **both** players have one line, so the tie-break below decides.

The Arduino doesn't need to "see" the result: it computes the new grid itself from the old one , which is exact because the coins have nowhere else to go.

### Who wins after a flip (THE RULE)

After the coins settle, count for each player the number of **separate lines of 4 or more** on the whole board (a line of 5, 6 or 7 still counts as one line).

1. **Nobody has a line** → the game continues. It is the *other* player's turn (the flipper's move was their turn).
2. **Only one player has lines, or one player has more lines** → that player wins.
3. **Both have the same number of lines** → **the player who triggered the flip wins** ("the flipper's reward": you took the risk and made it happen).

Why this rule: it is short enough to explain in one sentence at the demo, it always produces a result, and because the pattern is visible, players are encouraged to build it on purpose and must think about what the flip will do to the board. Alternatives we considered are in [DECISIONS.md](../DECISIONS.md).

## Scoring (kept across games in a session)

| Event | Points |
|---|---|
| Normal win | +3 |
| Win caused by a flip | +5 |
| Draw | +1 each |
| Cheating (single player) | −1 |

The score resets when the GUI sends "reset score" (e.g. a new pair of players).
