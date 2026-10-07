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

## Shopping list

**Budget goal: as cheap as possible.** The "Cheapest" column is the plan; the "Nicer" column is only if something cheap turns out unreliable. Prices are rough (EUR, AliExpress/Amazon-class; AliExpress is cheapest but takes 2–4 weeks, so order early). Buy 1–2 spares of anything under €3.

**Before buying anything, ask the Polimi labs and the course staff what you can borrow** (servos, power supplies, Arduinos, sensors) and how to get laser-cutter / 3D-printer access.

| # | Part (cheapest option) | Why | Cheapest | Nicer option |
|---|---|---|---|---|
| 1 | **Arduino Uno R3-compatible starter kit** (Elegoo-type: board, breadboard, wires, resistors, buttons, buzzer, a micro servo) | The brain + everything to learn with. The "Hard" computer level just thinks fewer moves ahead on this board. | €30–35 | Uno R4 Minima (faster, more memory) +€20 |
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
