# 03 · Hardware (beginner edition)

You don't need to invent the board. **Buy a normal Connect Four game (~€15) and modify it.** It already has a perfect grid, coins that fit, and a bottom release slider. All the work goes into the stand, the sensors and the motors around it.

## The big idea in one picture

```
            [ 7 LEDs: show the computer's move ]
            [ 7 IR sensors: detect coins       ]   <- FIXED sensor bar on the stand
       ┌────────────────────────────────────────┐
       │  gate A (servo)                          │
  ●====│  Connect Four grid (7 x 6)               │====●   <- horizontal axle through
 axle  │                                          │  axle      the middle, left to right
       │  gate B (servo)                          │
       └────────────────────────────────────────┘
   flip servo turns the whole grid 180° on the axle
   ─────────────────────── stand / base ───────────────────────
                       coin tray below (for reset)
```

Key design choices (and why):

- **The sensor bar and LEDs are fixed to the stand, not to the board.** The board rotates under them. That means no sensors need to be duplicated on both ends, and fewer wires twist when it flips.
- **A gate at each end of the grid.** Whichever end is on top is open (coins go in); the end at the bottom is closed (coins sit on it). Before a flip the top gate closes, so nothing falls out. After the flip the gates have swapped roles. The bottom gate also opens to release all coins at the start of a new game.
- **The axle goes through the centre of the board.** A balanced board needs much less motor force.

## Coin sensing and motion: options (proposal, 2026-10-27, not decided yet)

This section compares the practical ways to sense coins and to move the gates and the board. Nothing here is decided until the team picks; the recommended picks are marked ⭐.

### The trick that solves "both sides"

The board flips, so it is tempting to put sensors on **both ends of the board**. You don't need to. The coins always go in from the **same place in the room: the top**. So mount the sensors on a bar that is fixed to the stand, above the board, and let the board rotate underneath it. Whichever end of the board is on top after a flip, its 7 column openings line up under the same 7 sensors. One set of 7 sensors covers both orientations, and none of their wires move.

```
   coin ↓
  ┌──┬──┬──┬──┬──┬──┬──┐   <- fixed "entry bar" on the stand: 7 funnel slots,
  │▸◂│▸◂│  │  │  │  │  │      one sensor across each slot (▸ emitter, ◂ receiver)
  └──┴──┴──┴──┴──┴──┴──┘
        ~5–10 mm gap          <- the board must swing through here without touching
  ┌─────────────────────┐
  │ gate (open)          │   <- whichever end of the board is on top right now
  │   grid 7 × 6         │
 ●│ axle ··············· │●
  │                      │
  │ gate (closed)        │
  └─────────────────────┘
```

The one thing to get right is the **gap**. When the board turns on its centre axle, its corners sweep a circle. Its radius is half the board's height plus a few millimetres (it's half the diagonal of the board's height × thickness). The bar's bottom must sit just outside that circle, and nothing (gate servos, screws) may stick out past the board's ends. Then a coin falls through a 5–10 mm gap into the column; a funnel slot that guides the coin straight makes that reliable. Check it with a cardboard mock-up before cutting anything.

### Coin sensing options

| Option | How it works | Cost (7 columns) | Verdict |
|---|---|---|---|
| ⭐ **A. IR break-beam on the fixed entry bar** | An infrared LED shines across each slot to a receiver. A falling coin blocks the beam for a moment, so the Arduino knows which column got a coin. | €3–5 (DIY pairs) or €15–40 (ready modules) | **Recommended.** Very reliable, doesn't care about coin colour or room light much, 7 inputs, wires never move. |
| **B. Reflective IR module (TCRT5000) on the entry bar** | One small board per slot, looking sideways at the coin from a few mm away; it sees its own IR bouncing back off the coin. Has a little screw to set sensitivity. | ~€4 for a pack of 10 | **Good cheap backup.** Only one side of each slot to mount, 3 wires each. Needs tuning per sensor; slightly less robust than A. |
| C. Sensors on the board, at both ends | 7 sensors at each end, use the set that's on top. | 2× A | Works, but 14 sensors, 14 inputs (an Uno runs out of pins), and their wires twist with every flip. Only if the fixed bar can't be made to clear the board. |
| D. Microswitch or flap per column | The coin pushes a lever on its way in. | €3–5 | Last resort. Coins bounce and jam on levers; lots of fiddly tuning. |
| E. Magnets in coins + Hall sensors | Glue a small magnet into each of the 42 coins; a magnet sensor in each slot feels it pass. | €8–12 | Creative, but more work than A for the same result. The tempting extra (telling red from yellow by magnet direction) fails because a player can insert a coin either face forward. |
| F. Camera + computer vision | A webcam and a laptop program look at the whole board. | €0–20 | Sees colours and the whole grid, but it's a programming project of its own and depends on lighting. Too risky for this team. |
| G. Distance sensor per column (ultrasonic / laser ToF) | Measure the height of each stack from above. | €15–25 | Rejected: the column slot is too narrow, the beams bounce off the walls. |
| H. Load cell (scale) under the board | Weight goes up ~one coin's worth per drop. | €3–5 | Can't tell which column, so only useful as an extra check. |

**Why only "which column" is enough:** gravity decides the row, turn order decides the colour, and the Arduino computes the grid after a flip itself (see `docs/02-game-rules.md`). So one "coin passed column N" event per turn is all the game needs. Cheat detection also only needs the column.

**Timing (for whoever writes the code later):** a coin falling a few cm is moving about 1 m/s, so it blocks a beam for roughly 30–50 ms. Easily caught by a normal `loop()`. Count a coin when a beam goes blocked → clear, then ignore that column for ~300 ms so a bounce isn't counted twice.

### Gates (the "sliders" at both ends)

Each end of the board needs a gate: open when that end is on top (coins go in), closed when it is at the bottom (coins rest on it) or just before a flip, and open again at reset to drop all coins. The bought game's bottom slider is one gate; the other end needs a copy.

| Option | Cost each | Verdict |
|---|---|---|
| ⭐ **Micro servo (MG90S) + 3D-printed rack-and-pinion or push-rod** | €3–4 + printing | **Recommended.** A servo turning a small gear (pinion) that pushes a toothed strip (rack) *is* a linear actuator. Free designs exist (search "servo linear actuator rack pinion" on Printables/Thingiverse). The servo knows its own position, so open/closed needs no extra sensor. |
| Micro servo + rotating flap instead of sliding | €3–4 | Even simpler: a flap that swings under the column ends. Fine if the bought slider is hard to motorise. |
| 28BYJ-48 stepper + ULN2003 driver + printed lead screw | €3–4 | Works, but slower, needs a "home" switch and more code. No advantage here. |
| Real electric linear actuator (12 V) | €20–60 | Not recommended: expensive, slow, heavy on a rotating board, needs a motor driver and 12 V. |

Use metal-gear MG90S rather than plastic SG90: a gate holding a full column of coins upside down puts load on the gears. Mount the gate servos on the board's **front or back face**, not beyond its ends, so they don't hit the entry bar during the flip. Their wires ride the board: give them a loose loop (it only turns 180° and back, so nothing winds up).

### Flip motor (turning the board 180°)

Rough load: a balanced board on a centre axle only has to fight the coins that are off-centre, about 1–2 kg·cm in the worst case. Any servo below has a big safety margin, *if the axle really goes through the board's centre*.

| Option | Cost | Verdict |
|---|---|---|
| ⭐ **270° high-torque servo (e.g. DS3218 "270°" version), used from 0° to 180°** | €12–15 | **Recommended.** Goes to an angle by itself, no driver, no position sensor. Using a 270° servo for a 180° move means you never hit the end of its range, which is where cheap servos stall and buzz. |
| MG996R servo (~10 kg·cm) | €6–8 | Cheapest. Many MG996Rs only really turn ~120–160°, so test the range before building around it. Fallback: a 2:1 gear pair (printed) to double a 90° move. |
| DC gear motor + 2 limit switches (L298N or relay) | €6–10 | Robust and cheap: drive until the end switch clicks. A bit more wiring; good plan B if servos fail. |
| NEMA17 stepper + A4988 driver + belt | €15–20 | Precise but needs a home switch, a 12 V supply and more code. Overkill. |

Optional but cheap: one **limit switch (€1)** that the board presses when it reaches each end, so the Arduino can confirm the flip really finished before opening the gate.

### Recommended set, all together

| Part | Qty | Approx. cost |
|---|---|---|
| IR LED + IR phototransistor pairs (or 10× TCRT5000 modules) | 7 (+2 spare) | €3–5 |
| MG90S metal-gear micro servo (gates) | 2 (+1 spare) | €9–12 |
| 270° high-torque servo (flip), or MG996R | 1 | €6–15 |
| Limit switch (optional flip check) | 2 | €2 |
| 5–6 V, 3–4 A supply + 1000 µF capacitor | 1 | €9 |
| 3D-printed racks/pinions, servo hub, entry bar (Polimi printers/laser cutter) | — | material only |

This is close to the shopping list below (it upgrades the gate servos to MG90S and suggests a 270° flip servo). Pins stay as in the wiring table (D2–D8 sensors, D9 flip, D10–D11 gates). The Uno has no free pins left for limit switches, so if you want them, use a WS2812B strip for the column LEDs (one pin instead of seven) and put the switches on two of the freed pins.

### Test order (before building the real stand)

1. One IR pair on the breadboard: drop a real coin through a cardboard slot 50 times, count misses.
2. One MG90S pushing a printed rack: does it open and close the gate with coins resting on it?
3. Cardboard board on a dowel + cardboard entry bar: turn it by hand and check the gap; drop coins through the gap.
4. Flip servo on the cardboard board with 21 coins inside, slow sweep.

## Shopping list

**Budget goal: as cheap as possible.** The "Cheapest" column is the plan; the "Nicer" column is only if something cheap turns out unreliable. Prices are rough (EUR, AliExpress/Amazon-class; AliExpress is cheapest but takes 2–4 weeks, so order early). Buy 1–2 spares of anything under €3.

**Before buying anything, ask the Polimi labs and the course staff what you can borrow** (servos, power supplies, Arduinos, sensors) and how to get laser-cutter / 3D-printer access.

| # | Part (cheapest option) | Why | Cheapest | Nicer option |
|---|---|---|---|---|
| 1 | **Arduino Uno R3-compatible starter kit** (Elegoo-type: board, breadboard, wires, resistors, buttons, buzzer, a micro servo) | The brain + everything to learn with. | €30–35 | Uno R4 Minima (faster, more memory) +€20 |
| 9 | **IR LED + IR phototransistor pairs** (bags of 10–20) + resistors | One per column (+2 spare): a coin passing breaks the beam | €3–5 total | Ready-made IR break-beam modules, €2–6 each |
| 1 | **MG996R servo** (~10 kg·cm), check it reaches 180° | Flips the board. Servos go to an angle by themselves, so no position sensors needed. Works if the board is well balanced on its axle. | €6–8 | DS3218 20 kg·cm, €15 |
| 2 | **SG90 micro servo** (one may come in the kit) | The two gates | €2 each | MG90S metal gear, €4 each |
| 7 | **Plain LEDs** (from the kit) | Show which column the computer wants | €0 | WS2812B strip (any colour, one wire), €5–8 |
| 1 | **5 V, 3–4 A power supply** + barrel jack adapter (or borrow a lab bench supply) | Servos need their own power; the Arduino USB port is not enough | €8 | — |
| 1 | 1000 µF capacitor (10 V+) | Smooths servo power spikes | €1 | — |
| 1 | Wooden dowel or threaded rod as axle, through holes in the stand | So the board turns | €2–3 | 8 mm rod + bearings, €8 |
| — | Cardboard prototype first, then MDF/plywood offcuts, screws, hot glue | The stand, sensor bar, gates | €5–15 | Laser-cut acrylic |
| 1 | Connect Four game (second-hand or a cheap generic one) | The grid and coins | €5–15 | — |
| opt. | TCS34725 colour sensor | Upgrade: also check the coin colour | €8 | — |
| opt. | Limit switch | Upgrade: confirm the flip finished | €1 | — |

Total: roughly **€60–90** with the cheapest options, less if the lab lends parts. Split three ways that's €20–30 each.

## Wiring (proposed pin plan)

| Arduino pin | Goes to |
|---|---|
| D2–D8 | IR receiver signal, column 0 (left) to column 6 (right) |
| D9 | Flip servo signal |
| D10 | Gate A servo signal (the end on top at power-on) |
| D11 | Gate B servo signal |
| D12, D13, A1–A5 | Column LEDs: 7 plain LEDs, each through a 220 Ω resistor. (With a WS2812B strip instead, only D12 is needed, through a 330 Ω resistor.) |
| A0 | Buzzer (+) |
| 5V / GND | IR sensors and LED strip (7 LEDs at low brightness is fine) |

**Servo power:** servo red wires go to the **+6 V supply**, servo brown/black wires go to the **supply GND**, and **the supply GND must also connect to an Arduino GND pin** (common ground). Put the 1000 µF capacitor across the supply + and − (long leg to +). Never power the big servo from the Arduino 5 V pin.

**IR break-beams:** each pair has an emitter (2 wires: power) and a receiver (3 wires: power, GND, signal). Mount emitter and receiver facing each other across the column slot, just above the board. With `INPUT_PULLUP` the signal reads HIGH when clear and LOW when a coin blocks it.

## Mechanical build order

1. **Test everything on the table first**, no board: one sensor, then the LED strip, then one servo.
2. **Sensor bar:** a strip of wood/acrylic with 7 slots lined up with the game's column openings; emitter on one side of each slot, receiver on the other.
3. **Stand:** two uprights holding the axle at the centre height of the grid, with enough room for the grid to swing around (measure the diagonal!).
4. **Gates:** a thin strip under each end of the grid, hinged or sliding, moved by an MG90S. Test with real coins that nothing falls out when upside down.
5. **Flip servo:** fixed to one upright, its horn connected to the axle (servo horn → coupler → axle). The code should turn it slowly, not in one jump.
6. **Cable management:** the gate servos ride on the rotating board, so give their wires a long loose loop; it only turns 180° back and forth, never full circles, so they won't wind up.

## Safety

- Unplug power before changing wires.
- A 20 kg servo can pinch fingers; keep hands out of the flip area during tests.
- Double-check + and − on the power supply before plugging in; reversed polarity kills servos instantly.
