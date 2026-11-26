# 03 · Hardware (beginner edition)

The game is two players + the flip (single player was removed at the 28 Oct class review). The board needs to: sense which column each coin enters, hold coins at both ends, turn 180°, and release coins at the end. **Buy a cheap Connect Four game (~€10–15) for its coins and measurements**; the proposal below is to laser-cut our own grid around them (see "Hardware questions answered", question 6).

## The big idea in one picture

```
            [ LED strip: whose turn, pattern made, flip warning ]
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

- **The sensor bar and LED strip are fixed to the stand, not to the board.** The board rotates under them. That means no sensors need to be duplicated on both ends, and fewer wires twist when it flips.
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

**Why only "which column" is enough:** gravity decides the row, turn order decides the colour, and the Arduino computes the grid after a flip itself (see `docs/02-game-rules.md`). So one "coin passed column N" event per turn is all the game needs.

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

## Hardware questions answered (raised 28 Oct, proposal for the 4 Nov review)

The team's open doubts after the scope change (two players + flip only), answered one by one. The professor **approved** this approach on 4 Nov, then suggested magnets + Hall/reed sensors and an ESP32 board (see the next section, which is newer). Untested on hardware.

### 1. How do we know where every coin is? Do we need a sensor for each of the 42 holes?

**No. 7 sensors are enough, one per column, at the entry.** Think of a cashier counting people through 7 doors instead of watching every seat.

- The sensor says *which column* got a coin. **Gravity gives the row**: the Arduino keeps a count per column, so the coin lands on top of the ones already there.
- So the Arduino always holds the full 7 × 6 grid in memory, and sends it to the app after every coin (`STATE`). That is the "real-time position of the coins" on the GUI.
- **After a flip the Arduino computes the new grid itself**: each column's order is reversed. The coins have nowhere else to go, so no sensor is needed to "see" them.
- Why not 42 sensors: 42 × wiring on a board that rotates, about 6× the cost, and much more to go wrong. It would only be worth it if coins could appear without passing the entry, which can't happen here.

What can still go wrong, and the fix:

| Problem | Fix |
|---|---|
| A sensor misses a coin | Test 50 drops per column before building on it (milestone M1). Break-beams almost never miss. |
| Two coins at once | One coin per turn; the app shows whose turn it is. |
| A coin dropped during the flip | Impossible: the top gate closes as soon as the pattern is made. |
| Grid out of sync anyway | A "fix grid" screen in the app as a last resort (stretch goal). |

### 2. Can one Arduino handle all of this?

**Yes, an Uno is enough.** It has 20 pins (D0–D13, A0–A5). D0/D1 carry the USB link to ProtoPie, so 18 are usable. Analog pins A0–A5 also work as normal on/off pins.

| What | Pins | Uses |
|---|---|---|
| 7 column sensors | D2–D8 | 7 |
| Flip servo | D9 | 1 |
| Gate A servo, gate B servo | D10, D11 | 2 |
| LED strip (WS2812B): whose turn, flip warning | D12 | 1 |
| Buzzer | A0 | 1 |
| 2 limit switches (flip finished at 0° / 180°) | A1, A2 | 2 |
| **Total** | | **14 of 18**, 4 spare |

Only the colour-sensing upgrade (question 5) needs more: 7 *analog* readings, and the Uno has only 6 analog inputs. Three ways out, cheapest first:

1. **CD74HC4067 16-channel analog multiplexer** (€1–2): one chip that lets one analog pin read 16 sensors in turn, using 4 extra digital pins to choose which. Recommended.
2. **Arduino Nano** (€4–6): same chip as the Uno, but with 8 analog inputs (A6, A7 are analog-only).
3. **Arduino Mega** (€15–20): 54 digital and 16 analog pins. Only if you run out of everything.

Other pin-savers you may read about (74HC165 shift registers for many buttons, PCF8574 I2C expanders) are not needed at this size.

Power is the real limit, not pins: **all servos run from the separate 5–6 V supply** with the grounds connected (see Wiring below).

### 3. How do the gates (the "pull bars" that let coins out) work?

**How the shop game does it:** under the columns there is a strip with tabs. Slide it sideways by half a column and the gaps line up with the columns, so every coin drops out at once.

**Our version copies that at both ends of the board** (gate A and gate B):

```
 closed:  ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀    tabs under the 7 columns, coins rest on them
           │   │   │   │   │   │   │
 open:      ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀  strip slid by half a column pitch: gaps under columns
```

- **Strip:** 3 mm acrylic, laser cut (slides smoothly), running in a groove or two 3D-printed rails across the end of the board.
- **Motor:** an MG90S micro servo screwed to the board's front face. Its arm pushes the strip through a **push rod**: a piece of 1–1.5 mm steel wire with a Z-bend at each end (the trick RC model planes use for flaps). A servo arm of ~15 mm turning 60–90° gives 15–20 mm of travel, enough for half a column. If you need more travel, use the printed rack-and-pinion from the options above.
- **Holding:** the coins push *down* on the tabs, not sideways, so the servo only fights friction. A powered servo holds its position by itself.
- **Measure first:** column pitch (centre to centre), coin thickness and diameter. The tab width and slide distance come from those.

What each gate does during a game:

| Moment | Gate on top | Gate at the bottom |
|---|---|---|
| Playing | open (coins go in) | closed (coins rest on it) |
| Pattern made, waiting for the Flip button | **closes** | closed |
| Board turning | closed | closed: coins are trapped inside |
| Turn finished (the ends have swapped) | the old bottom gate, now on top, **opens** | the old top gate, now at the bottom, holds the coins |
| Game over → new game | open | **opens for ~2 s**, coins fall into the tray, closes again |

Both gates hold the full stack at some point, so build them identically.

### 4. What exactly happens during the flip?

1. A coin completes the pattern. The Arduino closes the top gate straight away, flashes the LED strip, and tells the app (`FLIP_READY`); the app plays an animation and shows **Flip** and **Skip**.
2. The player who made the pattern chooses (`FLIP||1` or `FLIP||0`). **Skip:** the top gate reopens, the LEDs stop, the other player's turn. **Flip:** carry on below. The choice doubles as a safety step: nobody's hands are in the board.
3. Warning: the LED strip flashes and the buzzer beeps for ~2 s.
4. The flip servo turns 180° **slowly** (2–3 s, in small steps). Slowly matters: the coins slide along their column as it passes horizontal instead of crashing onto the far gate.
5. Wait ~1 s for the coins to settle. If you fitted the limit switch, check it is pressed.
6. Open the gate that is now on top. The other gate (closed) is now the bottom.
7. The Arduino sends the new grid and the result (`FLIP_DONE`, then `WIN`/`FLIP_WIN` or the next `TURN`).

Mechanical rules for the flip:

- **Balance:** the axle must go through the centre of the loaded board. Test by hand: let go at any angle and it should stay there. Then even a cheap servo is enough.
- **Wires on the board:** the two gate servos ride on the board. Run their wires along the axle with a loose loop; with one flip per game the board only goes 0° → 180°, and back to 0° at the next new game (after the coins are released), so nothing winds up.
- **Clearance:** the fixed entry bar must clear the turning board (see "The trick that solves both sides" above).

### 5. How do we know which colour the coin is?

First: **in a two-player game, the colour already comes from the turn order.** Red starts and players alternate, so the Arduino knows the colour of every coin without a sensor. A sensor only adds value if someone plays out of turn or grabs the wrong colour; then the app could warn "Wrong colour!".

| Option | How | Cost (7 columns) | Verdict |
|---|---|---|---|
| ⭐ **A. Turn order, no sensor** | The app shows whose turn it is, big and in that colour; the LED strip lights in that colour too. | €0 | **Start here.** Zero risk, works from day one. |
| ⭐ **B. Green LED + light sensor per column (upgrade)** | In each entry slot, a green LED and a phototransistor sit side by side looking at the passing coin. Yellow plastic reflects green light strongly; red plastic absorbs it. So yellow reads bright, red reads dark, an empty slot (black wall behind) reads darkest. One sensor gives *coin passed* and *its colour*, so it could even replace the IR beam. | ~€4 + €2 multiplexer | **Best upgrade** once the game works. Use a phototransistor (e.g. TEPT5700 or any "ambient light" phototransistor), **not an LDR**: an LDR reacts too slowly for a falling coin. Test one on the breadboard with your real coins first. |
| C. TCS34725 colour sensor module per column | Proper RGB colour sensor on I2C. All 7 have the same address, so they also need a TCA9548A I2C multiplexer. | €45–60 | Accurate but expensive and more code; reading time is tight for a falling coin. |
| D. Camera | Phone/webcam + a laptop program | — | No: a whole extra project. |

**Plan:** A now; build one B sensor early on the breadboard to see if red and yellow give clearly different readings. If they do, add it after milestone M2 (game playable).

### 6. Materials, and which "model" to build

**The grid (where the coins sit).** Two ways:

| Option | What | Verdict |
|---|---|---|
| Modify a bought game | Cheap game (€10–15) gives grid, 42 coins and one bottom slider. | Its top end is moulded for coin entry, so fitting a second gate there is hard. |
| ⭐ **Laser-cut your own grid, keep the bought coins** | A sandwich of 3 layers: **clear 3 mm acrylic front**, a **middle layer with 7 vertical slots** (plywood/MDF, as thick as a coin + ~1 mm), **clear 3 mm acrylic back**, bolted with M3 screws. You see the coins through the clear sheets; no holes needed. | **Recommended.** Gates, axle mounts and servo mounts can be designed into the same file, and you control every gap. Still buy the game: for the coins and to measure. |

This changes the earlier default ("build on a bought game") to "build our own grid, reuse the bought coins". It's a proposal; see DECISIONS.md.

**Everything else:**

| Part | Material / method | Approx. cost |
|---|---|---|
| Stand: base + 2 uprights | 6 mm plywood or MDF, laser cut, glued and screwed | €5–8 per sheet |
| Axle | 8 mm steel rod or M8 threaded rod, through two **608 skateboard bearings** (8 mm hole, €1 each) pressed into the uprights | €4–6 |
| Servo-to-axle coupling | 3D-printed hub; the servo horn screws onto it | lab filament |
| Entry bar with 7 funnel slots | 3D printed (holds the sensors in exact spots) or stacked laser-cut layers | lab filament |
| Gates | 3 mm acrylic strips in 3D-printed rails; 1–1.5 mm steel wire push rods | €3–5 |
| Coin tray | Laser-cut box or drawer in the base | — |
| Electronics | Arduino + breadboard in the base, away from the turning board | — |
| Screws | M3 screws and nuts kit | €5 |

**Modelling tools:** Onshape (free, in the browser) or Fusion 360 (free education licence) for the 3D model and the laser-cut outlines; boxes.py or MakerCase generate finger-jointed boxes for the base in minutes. Laser cutters take 2D DXF/SVG files.

**Build order:** measure the coins → cardboard mock-up of grid + stand + entry bar (turn it by hand) → MDF version → acrylic for the visible parts.

## Professor's feedback (4 and 18 Nov): magnets, Hall sensors, ESP32

This updates the proposal above. Where the two disagree, this section is newer. Untested on hardware.

**What the professor said**
- 4 Nov: the hardware proposal was **approved**. Next step: make the final components list and get the parts ready. Suggested sensors: **reed sensors and Hall sensors**, with **magnets inside the coins** (Airika's notes).
- 18 Nov: **don't buy an Arduino Mega; use an ESP32-based board**, so it can read up to 8 analog values.

**How the magnet idea works**
- Glue a small neodymium disc magnet (e.g. 6 × 2 mm, ~€8 for 50) into the centre of each of the 42 coins: drill a shallow hole or press it in, then a drop of glue.
- In each of the 7 entry slots, a magnet sensor sits in the slot wall. When a coin falls past, the sensor sees the magnet. Same fixed entry bar, same "one set of 7 covers both sides" idea; only the sensor type changes.
- **Hall sensor (recommended):** an electronic chip, no moving parts, very fast. The analog type (e.g. **SS49E**, ~€0.30 each) gives a number that rises or falls with the magnet's strength and pole. It needs an analog input per column, which is why the professor suggested the ESP32.
- **Reed sensor (simpler, cheaper):** a tiny glass switch that closes near a magnet; reads like a button on any digital pin. But the glass breaks easily, it can "bounce", and it may be too slow or not sensitive enough for a falling coin. Good as a quick first test.
- **Colour:** the magnet's pole could tell red from yellow (red coins north-side front, yellow south-side front), but a player can drop a coin in either way round, which flips the pole. So keep **colour from turn order** and treat the pole reading as a bonus check at most.
- **Watch out:** the sensor only sees a small magnet within about 5–10 mm, so the slot must guide the coin close to it. Coins with magnets will cling to each other a little in the tray and stack differently; test a few before doing all 42.

**ESP32 instead of the Uno**
- An ESP32 board costs about €5–10, is programmed in the same Arduino IDE, and has many analog inputs, plus Wi-Fi and Bluetooth built in (useful later for the phone-only idea).
- It runs on **3.3 V, not 5 V**: power the Hall sensors from its 3V3 pin so their output never goes above 3.3 V. Servos still run from the external 5–6 V supply (their 3.3 V signal wire usually works; test one). The LED strip's data line usually works at 3.3 V too.
- **Which board:** an **ESP32-S3 DevKit** has 10 analog pins on its first converter (GPIO1–GPIO10), enough for 7 sensors with room to spare. On a classic ESP32 DevKit only 6 of those pins are exposed, and the others stop working when Wi-Fi is on. Since we talk to ProtoPie Connect over USB, either board works, but the S3 is the safer pick.
- Proposed ESP32-S3 pin plan (check the pin labels on the actual board):

| ESP32-S3 pin | Goes to |
|---|---|
| GPIO1–GPIO7 | Hall sensor outputs, column 0 (left) to 6 (right) |
| GPIO15 | Flip servo signal |
| GPIO16, GPIO17 | Gate A and gate B servo signals (if the gates are motorised) |
| GPIO18 | LED strip data (330 Ω resistor) |
| GPIO8 | Buzzer |
| GPIO9, GPIO10 | Limit switches (flip at 0° / 180°) |
| 3V3 / GND | Hall sensors; all grounds joined with the external supply |

**Gates: manual or motorised?** The team (Airika, Danny) is considering opening and closing the gates **by hand** to save motors. That works for releasing the coins at the end of a game. During a flip, though, the top gate must be closed before the board turns, so with manual gates a player closes it, then presses Flip; the Arduino can't check this unless a switch is added. Still open.

**Fabrication:** 3D printing at the Polimi OpenLab (a safety course is needed first) or at the TED Laboratory (Bovisa campus, Durando); contact noted by Airika: gabtiele.viscardi@polimi.it (as written on the board, check the spelling).

## 3D-printable stand, concept v0 (24 Nov 2026, proposal)

Designed around the ordered parts (LAFVIN ESP32 DevKit V1 kit, HOTUT 13 kg 180° servo, EPLZON A3144 Hall sensors, 4 × 2 mm magnets). Source: [`cad/flip_board.scad`](../cad/flip_board.scad) (parametric OpenSCAD; STL exports live in the project files, not in git). Untested on hardware.

- **Smaller than a shop game:** printed coins 24 × 5 mm with a magnet pocket; board 215 × 171 mm; every part fits a 220 × 220 mm bed (uprights placed diagonally). About 450 g of PLA and ~35 h of printing (rough).
- **Nothing electrical turns.** The board is plastic, coins and magnets only. Sensors sit in a fixed entry bar across the top, the servo on the left upright, the ESP32 + breadboard on the base. No wires twist.
- **Axle:** left to right through the exact middle of the coin slots (y = 0, z = 0). Column 0 stays left after the flip and each slot lands under the same sensor. Left: servo through a window in the upright, 2-arm horn screwed to the board's boss (direct drive). Right: printed 8 mm pin on the upright in a hole in the board's boss. Board corners sweep an 86.6 mm radius; the entry bar sits 3 mm outside it (coin falls across a ~4 mm gap).
- **Board:** two identical `core_half` prints (front + back, round windows, ends included), bolted with 12 M3 screws.
- **Gates (by hand):** see v1.2 below (side-sliding ladder strip). The player closes the top gate before pressing Flip.
- **Sensors:** A3144 is digital and reacts to the **south** pole only, and a coin can go in either way round, so each column has **two sensors**, one in the front wall and one in the back wall of a narrow throat (coin + 0.6 mm), outputs wired together (14 sensors, still 7 inputs). Magnet flush with the coin face, 0.8 mm wall: ~2 mm gap, roughly 1100 gauss vs the A3144's up-to-350 gauss switch point. At 4 mm it drops to ~330 gauss, so keep walls thin and test first with `sensor_test`. If weak: stack two magnets per coin.
- **Wiring (from the team's Tinkered circuit):** sensor OUT pairs → GPIO 13, 14, 27, 26, 25, 33, 32 (column 0 → 6), each with 10 kΩ pull-up to **3V3**; sensor VCC → VIN (5 V from USB), GND common. Servo signal → GPIO 4; servo power from a separate 5 V ≥ 3 A charger with 1000 µF across it, common GND. Servo pulse range must be widened from 1000–2000 µs to roughly 500–2500 µs for 180° (find the real ends by testing).
- **Board start position:** either; the servo alternates 0° ↔ 180°, no need to turn back between games.
- **Magnets:** 42 coins (v1.2 dropped the gate magnets).
- **v1 design pass (25 Nov):** tapered A-shaped uprights (60 mm foot, 36 mm top) with cut-outs, pin with a cone root and chamfered tip, slimmer chamfered sensor bar (19 mm deep), slot lead-in funnels on the end caps, 18 mm chamfered windows, hex pockets for the M3 bolts, rounded gate tabs, lighter tray with finger notch, gusseted brackets. About 17% less plastic (~375 g, ~29 h, rough); every functional measurement unchanged; no supports needed.
- **v1.2 (26 Nov, after Danny's review):**
  - **Gates slide side to side** like the shop game: a ladder strip (two rails outside the coin slot, 7 rungs 3 mm wide). Closed: rungs under the column centres. Open: slide 13.75 mm (half a column) so the rungs hide under the ribs. It slides along the flip axle, so gravity can't open it during the flip. Knobs on both faces. The strip is trapped between the two board halves; the separate end caps and the gate magnets are gone.
  - **Servo joint:** the 2-arm horn sits in a horn-shaped pocket (3.5 mm deep) in the board's boss; no screws between horn and board (they couldn't be reached once assembled). The board is trapped between the uprights (≤ 1 mm side play). Horn size is parametric (`horn_*`): measure it.
  - **Cable channels:** 4 × 3 mm channel along the back edge of each upright's outer face; sensor wires run in grooves along the sensor bar.
  - Assembly guide with every part and screw, plus a simulation of a round: Danny's artifact "Flip Board Assembly".
- **Test order:** sensor_test + one sensor (50 drops each way round) → servo end points → board with coins flipped by hand → full stand.

## Shopping list

**Budget goal: as cheap as possible.** The "Cheapest" column is the plan; the "Nicer" column is only if something cheap turns out unreliable. Prices are rough (EUR, AliExpress/Amazon-class; AliExpress is cheapest but takes 2–4 weeks, so order early). Buy 1–2 spares of anything under €3.

**Before buying anything, ask the Polimi labs and the course staff what you can borrow** (servos, power supplies, Arduinos, sensors) and how to get laser-cutter / 3D-printer access.

| # | Part (cheapest option) | Why | Cheapest | Nicer option |
|---|---|---|---|---|
| 1 | **Arduino Uno R3-compatible starter kit** (Elegoo-type: board, breadboard, wires, resistors, buttons, buzzer, a micro servo) | The brain + everything to learn with. | €30–35 | Uno R4 Minima (faster, more memory) +€20 |
| 9 | **IR LED + IR phototransistor pairs** (bags of 10–20) + resistors | One per column (+2 spare): a coin passing breaks the beam | €3–5 total | Ready-made IR break-beam modules, €2–6 each |
| 1 | **MG996R servo** (~10 kg·cm), check it reaches 180° | Flips the board. Servos go to an angle by themselves, so no position sensors needed. Works if the board is well balanced on its axle. | €6–8 | DS3218 20 kg·cm, €15 |
| 2 | **MG90S metal-gear micro servo** (+1 spare) | The two gates; metal gears because each gate holds a full stack | €3–4 each | — |
| 1 | **WS2812B LED strip**, 10–15 LEDs (60 LEDs/m, cut to length) | Whose turn (in that colour), flashing when the pattern is made, flip warning; one data wire | €3–6 | — |
| 1 | **5 V, 3–4 A power supply** + barrel jack adapter (or borrow a lab bench supply) | Servos need their own power; the Arduino USB port is not enough | €8 | — |
| 1 | 1000 µF capacitor (10 V+) | Smooths servo power spikes | €1 | — |
| 1 | 8 mm rod or M8 threaded rod + two 608 bearings | The axle the board turns on | €4–6 | — |
| — | Cardboard prototype first, then 6 mm MDF/plywood, 3 mm clear acrylic, M3 screws | Stand, grid sandwich, entry bar, gates | €15–25 | — |
| 1 | Connect Four game (second-hand or a cheap generic one) | The 42 coins, and the dimensions to design around | €5–15 | — |
| 2 | Limit switch | Confirm the flip finished (0° and 180°) | €1 each | — |
| opt. | 7 green LEDs + 7 visible-light phototransistors + CD74HC4067 multiplexer | Upgrade: coin colour (question 5) | €5–6 | — |
| later | **Bluetooth module**: HC-05 (Android only, ~€4) or HM-10 BLE (iPhone and Android, ~€5) | Final-product idea: the phone app talks to the board without a PC. Not needed for the course prototype (see [04-software.md](04-software.md)). | €4–5 | — |

Total: roughly **€70–100** with the cheapest options, less if the lab lends parts. Split three ways that's €20–30 each.

## Wiring (proposed pin plan)

| Arduino pin | Goes to |
|---|---|
| D2–D8 | IR receiver signal, column 0 (left) to column 6 (right) |
| D9 | Flip servo signal |
| D10 | Gate A servo signal (the end on top at power-on) |
| D11 | Gate B servo signal |
| D12 | WS2812B LED strip data, through a 330 Ω resistor |
| A0 | Buzzer (+) |
| A1, A2 | Limit switches (flip at 0°, flip at 180°), other leg to GND, use `INPUT_PULLUP` |
| D13, A3–A5 | Spare. The colour upgrade's multiplexer would use 4 of them plus one analog pin. |
| 5V / GND | IR sensors. The LED strip's power goes to the external 5 V supply (see "Board LEDs" below); only its data wire and GND go to the Arduino. |

**Bluetooth module (only if we add one later):** the Uno has no free pins with plain LEDs. Switch the column LEDs to a WS2812B strip (D12 only), then use A1 (Arduino RX ← module TX) and A2 (Arduino TX → module RX) with `SoftwareSerial`. The module's RX pin takes 3.3 V, so put a voltage divider (1 kΩ + 2 kΩ) between A2 and RX. Module VCC → 5 V, GND → GND. Untested on hardware.

**Servo power:** servo red wires go to the **+6 V supply**, servo brown/black wires go to the **supply GND**, and **the supply GND must also connect to an Arduino GND pin** (common ground). Put the 1000 µF capacitor across the supply + and − (long leg to +). Never power the big servo from the Arduino 5 V pin.

**IR break-beams:** each pair has an emitter (2 wires: power) and a receiver (3 wires: power, GND, signal). Mount emitter and receiver facing each other across the column slot, just above the board. With `INPUT_PULLUP` the signal reads HIGH when clear and LOW when a coin blocks it.

## Board LEDs (pattern made, whose turn, flip warning)

Danny (2026-11-04): when the pattern is made, the LEDs on the board flash while the app plays its animation.

- **What:** one WS2812B ("NeoPixel") strip, 10–15 LEDs. Every LED can be any colour, and the whole strip needs **one data wire** (D12, already in the pin plan; no new pins).
- **Where:** on the **fixed stand**, not the turning board: along the front of the entry bar, or around the base. Then no wires cross the flip. Light shining up through clear acrylic edges looks good.
- **What it shows:** red or yellow glow = whose turn; fast rainbow/white flashing = pattern made, choose Flip or Skip; red flashing + beep = the board is about to turn; winner's colour = game over.
- **Wiring:** strip 5V → external 5 V supply +; strip GND → supply − **and** Arduino GND; strip DIN → 330 Ω resistor → D12. A 1000 µF capacitor across the strip's 5V/GND (the servo one can be shared if it's close).
- **Power:** each LED can draw up to 60 mA at full white. 15 LEDs at full white = 0.9 A, so keep brightness low in code (about 25%) and feed the strip from the external supply, not the Arduino's 5 V pin. Code library: Adafruit NeoPixel or FastLED.

## Mechanical build order

1. **Test everything on the table first**, no board: one sensor, then the LED strip, then one servo.
2. **Sensor bar:** a strip of wood/acrylic with 7 slots lined up with the grid's column openings; emitter on one side of each slot, receiver on the other.
3. **Stand:** two uprights holding the axle at the centre height of the grid, with enough room for the grid to swing around (measure the diagonal!).
4. **Gates:** a thin strip under each end of the grid, hinged or sliding, moved by an MG90S. Test with real coins that nothing falls out when upside down.
5. **Flip servo:** fixed to one upright, its horn connected to the axle (servo horn → coupler → axle). The code should turn it slowly, not in one jump.
6. **Cable management:** the gate servos ride on the rotating board, so give their wires a long loose loop; it only turns 180° back and forth, never full circles, so they won't wind up.

## Safety

- Unplug power before changing wires.
- A 20 kg servo can pinch fingers; keep hands out of the flip area during tests.
- Double-check + and − on the power supply before plugging in; reversed polarity kills servos instantly.
