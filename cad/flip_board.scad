// Connect Four Flip: parametric 3D-printable board, v2 screw-free (2026-11-26)
// Untested on hardware. Measure your real parts and change the numbers below.
//
// Pick a part:  openscad -D 'part="coin"' -o coin.stl flip_board.scad
// Parts: coin, core_half, gate, board_clip, entry_bar, lock_pin, upright_left, upright_right,
//        axle_pin, servo_strap, foot_socket, tray, sensor_test, assembly (preview only)
// No screws: halves join with pegs + snap clips, servo with a snap strap, uprights stand in
// glued foot sockets, the right pivot is a push-in pin, the sensor bar drops in and is pinned.
//
// Coordinates (assembly): x = across the columns (column 0 on the left, -x)
//                         y = up, z = towards the player (front)
// The flip axle is the x axis through (y=0, z=0): the exact middle of the
// coin slots. That is what makes the slots land under the same sensors
// after a 180 degree turn.

part = "assembly";
$fn = 48;

// ---------- things you measure / choose ----------
coin_d   = 24;    // printed coin diameter (keeps every part inside a 220 mm bed)
coin_t   = 5;     // coin thickness
mag_d    = 4;     // magnet 4 x 2 mm
mag_h    = 2;
fit      = 0.3;   // printing clearance; raise to 0.4 if parts are too tight

// MG996R-class servo (HOTUT 13 kg). Measure yours!
servo_w        = 20.0;   // body width
servo_l        = 40.5;   // body length (without flanges)
servo_hole_pitch = 48.5; // flange screw holes, centre to centre along the length
servo_hole_gap   = 10.0; // flange screw holes, across the width
servo_hole_slot  = 1.0;  // holes are slots: fit any spacing from 48.5 to 49.5 mm
servo_spline_off = 10.2; // spline centre to the near end of the body
servo_flange_to_horn = 16.5; // flange top surface to the outer face of the 2-arm horn
servo_case_above_flange = 9.2;  // flange top surface to the top of the case
servo_case_below_flange = 28;   // flange top surface to the bottom of the case
// The 2-arm horn that comes with the servo. Measure yours!
horn_len   = 38;    // tip to tip
horn_hub_d = 10;    // round middle part
horn_tip_w = 5.5;   // width of an arm near its tip
horn_t     = 2.8;   // thickness of the arms
horn_hub_h = 5.5;   // how far the hub sticks out towards the servo
horn_pocket_d = horn_t + 0.7;   // depth of the horn-shaped pocket in the board's left boss

// ---------- derived board numbers ----------
function colx(c) = (c-3)*(coin_d + 1.5 + 2);
col_w   = coin_d + 1.5;          // slot width
rib     = 2;
pitch   = col_w + rib;           // 27.5
inner_w = 7*col_w + 6*rib;       // 190.5
side    = 6;
board_w = inner_w + 2*side;      // 202.5
rows_h  = 6*coin_d + 1;          // 145, room for 6 coins
ch      = coin_t + 1;            // slot depth (z), 6
plate   = 3;                     // front / back plate
zf      = ch/2 + plate;          // 6 = half board thickness
cap_h   = 13;                    // end cap height (y)
cap_z   = zf;                    // ends are as thick as the board now (gate is inside)
board_h = rows_h + 2*cap_h;      // 171
boss_l  = 6;  boss_y = 22;       // axle bosses on both sides
win_d   = 18;                    // round windows to see the coins

// Gate = a sliding "ladder" strip in each end of the board, like the shop game's slider.
// Two thin rails run outside the coin slot (front and back); 7 narrow rungs cross the slot.
// Closed: each rung sits under the middle of a column and the coins rest on it.
// Open: slide it sideways half a column (13.75 mm); the rungs hide under the ribs, coins fall through.
// It slides along the flip axle, so gravity can never push it open during the flip.
gate_t   = 3.0;                  // strip thickness (y)
groove   = gate_t + fit;         // its slot in the board
rung_w   = 3.0;                  // rung width (x): rib 2 mm + 0.5 each side, coin clearance is 0.75
rail_z0  = ch/2 + 0.2;           // rails run from here...
rail_z1  = zf - 1.0;             // ...to here (1 mm of board skin stays outside)
gate_shift = pitch/2;            // 13.75 mm sideways = open
gate_len_half = colx(6) + 1.5;   // rails reach just past the outer rungs
groove_x = gate_len_half + gate_shift + fit;   // slot length each side of centre
knob_x   = -gate_shift/2;        // knob position when closed (slot is symmetric about the middle)
// sweep circle of the turning board (corners of the end caps)
R_sweep = sqrt(pow(board_h/2,2) + pow(cap_z,2));   // ~86.6
bar_y0  = ceil(R_sweep + 3);     // bottom of the fixed entry bar (3 mm clearance)
bar_h   = 26;  bar_z = 9.5;  bar_w = 210;  funnel_z = 7.5;
throat  = coin_t + 0.6;          // slot at the sensors: coin can't wander away from them
throat_h = 16;
sens_wall = 0.8;                 // plastic between sensor face and coin: keep it thin!
sens_y  = bar_y0 + 12;           // sensor height (legs hang down into the wire trench below)
trench_y0 = bar_y0 + 0.8; trench_y1 = bar_y0 + 7.3; trench_d = 4;   // wire trench along the bottom of both faces
xhole_x = 100;                   // wire hole through the bar's solid right end: back bundle -> front
a3144   = [4.5, 3.6, 1.9];       // pocket for the A3144 body (x, y, z)

base_y  = -(ceil(R_sweep) + 3 + 25);   // top of the base board (-115)
up_t    = 8;  up_z = 22;                // upright thickness and half depth
x_right = board_w/2 + boss_l + 3;       // inner face of right upright
horn_x  = -(board_w/2 + boss_l) + horn_pocket_d - 0.5;  // board-side face of the horn (sits in the pocket)
x_left  = horn_x - servo_flange_to_horn + up_t;          // inner face of left upright
pin_d   = 8;

// ---- screw-free joints (v2) ----
peg_d   = 3.6;  peg_h = 3.5;  peg_hole = 3.9;   // board halves: pegs on the left side, holes on the right
clip_y  = 48;   clip_w = 8;   clip_reach = 12;  // 4 snap clips over the board's side edges
clip_t  = 1.6;  clip_bump = 0.6;
lock_d  = 3.5;  lock_hole = 3.8;                 // lock pins (sensor bar)
strap_w = 8;    strap_t = 2.2;                    // servo strap
strap_z0 = 13.6;                                  // inner face of the strap legs (servo is +-10)
slot_z0 = 12.0; slot_z1 = 16.0;                   // strap slots through the left upright
sock_h  = 12;   sock_wall = 3;  sock_fl = 12;     // foot sockets: height, wall, glue flange
tongue_l = 4.6; tongue_z = 4;  tongue_h = 16;    // sensor bar end tongues

// ---- electronics on the base (LAFVIN kit). Measure yours! ----
esp_l = 51.5;  esp_w = 28.4;  esp_pcb = 1.6;   // ESP32 DevKit V1 30-pin board
esp_hole_d = 3.0;  esp_hole_in = 2.6;          // corner holes: diameter, centre inset from the edges
esp_stand = 18;                                 // header pins point down: room for dupont plugs
bb = [165, 10, 55];                             // 830-point breadboard (x, height, z)
base_d0 = 70;  base_d1 = -135;                  // base board front / back edge (z)
bb_pos  = [-145, base_d1 + 6];                  // breadboard corner (x, z)
esp_pos = [-124.5, -103];                       // ESP32 centre (x, z): plugged into the breadboard's left end, USB to the left
batt = [28, -131, 62, 58, 15];                  // 4 x AA holder for the servo: x, z, length, depth, height


function rowy(r) = -rows_h/2 + 0.5 + coin_d/2 + r*coin_d;

// ================= coin =================
module coin() {
  difference() {
    union() {
      cylinder(d=coin_d-1, h=coin_t);
      translate([0,0,0.5]) cylinder(d=coin_d, h=coin_t-1);
      cylinder(d1=coin_d-1, d2=coin_d, h=0.5);
      translate([0,0,coin_t-0.5]) cylinder(d1=coin_d, d2=coin_d-1, h=0.5);
    }
    // magnet pocket, south pole facing OUT of the coin
    translate([0,0,coin_t-mag_h-0.1]) cylinder(d=mag_d+fit, h=mag_h+1);
    // ring on the magnet side, so you can see which face has it
    translate([0,0,coin_t-0.4]) difference() { cylinder(d=coin_d-5, h=1); cylinder(d=coin_d-6.6, h=1); }
  }
}

// ================= helpers =================
module rr2(x, y, r) { offset(r=r) offset(delta=-r) square([x, y]); }      // rounded rectangle
M_XZY = [[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]];   // (a,b,c) -> (x=a, y=c, z=b)
M_YZX = [[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]];   // (a,b,c) -> (x=c, y=a, z=b)
module rbox(sz, r=2, c=0) {   // box from origin: rounded vertical edges r, chamfered top/bottom edges c
  if (c > 0) hull() {
    translate([c, c, 0]) linear_extrude(sz[2]) rr2(sz[0]-2*c, sz[1]-2*c, max(0.01, r-c));
    translate([0, 0, c]) linear_extrude(sz[2]-2*c) rr2(sz[0], sz[1], r);
  } else linear_extrude(sz[2]) rr2(sz[0], sz[1], r);
}
edge_c = 1;   // standard chamfer on visible edges

module horn_outline(gap=0) {   // 2D, in (z, y) seen along the axle
  hull() {
    circle(d=horn_hub_d+2*gap);
    for (e=[-1,1]) translate([0, e*(horn_len/2-horn_tip_w/2)]) circle(d=horn_tip_w+2*gap);
  }
}
// ================= board core: two identical halves =================
// Assembly coords for the FRONT half (z >= 0). The back half is the same part turned over.
module boss_shape() {   // rounded axle boss, profile in y-z, extruded along x
  multmatrix(M_YZX) linear_extrude(boss_l) translate([-boss_y, -zf]) rr2(2*boss_y, 2*zf, 4);
}
module core_half() {   // one half of the whole board, ends included
  difference() {
    union() {
      // plate over the rows
      translate([-board_w/2, -rows_h/2, ch/2]) cube([board_w, rows_h, plate]);
      for (sg=[-1,1]) translate([sg>0 ? inner_w/2 : -board_w/2, -rows_h/2, 0]) cube([side, rows_h, zf]);
      for (c=[0:5]) translate([colx(c)+col_w/2, -rows_h/2, 0]) cube([rib, rows_h, ch/2]);
      // solid ends (were separate end caps), rounded outer corners
      for (e=[-1,1]) translate([0, e*(rows_h/2+cap_h/2), 0]) intersection() {
        translate([-board_w/2, -cap_h/2-0.01, 0]) cube([board_w, cap_h+0.02, zf]);
        translate([0, -e*5, 0]) linear_extrude(zf) offset(r=5) square([board_w-10, cap_h+10-0.02], center=true);
      }
      for (sg=[-1,1]) intersection() {
        translate([sg>0 ? board_w/2-0.01 : -board_w/2-boss_l+0.01, 0, 0]) boss_shape();
        translate([-200, -50, 0]) cube([400, 100, zf]);
      }
    }
    for (c=[0:6], r=[0:5]) translate([colx(c), rowy(r), 0]) {
      cylinder(d=win_d, h=20);
      translate([0,0,zf-edge_c]) cylinder(d1=win_d, d2=win_d+2*edge_c+0.2, h=edge_c+0.01);
    }
    for (sg=[-1,1]) translate([sg*board_w/2, 0, zf]) rotate([0,45,0]) cube([2*edge_c, 400, 2*edge_c], center=true);
    for (e=[-1,1]) translate([0, e*board_h/2, zf]) rotate([45,0,0]) cube([400, 2*edge_c, 2*edge_c], center=true);
    for (e=[-1,1]) {
      // coin tunnels through the ends, with a lead-in at the outer face
      for (c=[0:6]) {
        translate([colx(c)-col_w/2, -1000*0 + (e>0 ? rows_h/2-1 : -board_h/2-1), -1]) cube([col_w, cap_h+2, ch/2+1]);
        translate([colx(c), e*board_h/2, 0]) hull() {
          translate([-col_w/2-1, -0.01, -1]) cube([col_w+2, 0.02, ch/2+1+1.5]);
          translate([-col_w/2, -e*2.5, -1]) cube([col_w, 0.02, ch/2+1]);
        }
      }
      // gate slot: right next to the rows, across the whole width, 1 mm skin left outside
      translate([-groove_x, e>0 ? rows_h/2 : -rows_h/2-groove, -1]) cube([2*groove_x, groove, rail_z1+fit+1]);
      // window for the knob in the outer skin
      translate([knob_x-1.9, e>0 ? rows_h/2 : -rows_h/2-groove, rail_z1-0.5]) cube([gate_shift+3.8, groove, 5]);
    }
    for (sg=[-1,1]) translate([sg*(board_w/2+boss_l+1), 0, 0]) rotate([0,90,0])
      translate([0,0,sg>0 ? -(boss_l+1+3) : -1]) cylinder(d=pin_d+0.6, h=boss_l+1+3);
    translate([board_w/2+boss_l+0.01, 0, 0]) rotate([0,-90,0]) cylinder(d1=pin_d+2.6, d2=pin_d+0.6, h=1);
    for (sg=[-1,1]) translate([sg*(board_w/2+boss_l+0.01), 0, 0]) rotate([0, sg*-90, 0]) translate([0,0,-0.01])
      linear_extrude(horn_pocket_d+0.01) horn_outline(0.3);
    // peg holes on the right side (the other half's pegs go in here)
    for (yy=[-80,-20,20,80]) translate([inner_w/2+side/2, yy, -0.01]) {
      cylinder(d=peg_hole, h=peg_h+0.5);
      cylinder(d1=peg_hole+0.8, d2=peg_hole, h=0.4);
    }
    // grooves for the snap clips' bumps, both sides
    for (sg=[-1,1], e=[-1,1]) translate([sg*(board_w/2-clip_reach+1.1), e*clip_y, zf-clip_bump-0.2]) cube([2.4, clip_w+1, 2], center=true);
  }
  // pegs on the left side, pointing at the other half
  for (yy=[-80,-20,20,80]) translate([-(inner_w/2+side/2), yy, -peg_h]) {
    translate([0,0,0.6]) cylinder(d=peg_d, h=peg_h);
    cylinder(d1=peg_d-1, d2=peg_d, h=0.6);
  }
}

// snap clip over a side edge of the board (print 4). Local: board edge at x=0, board between z=+-zf.
module board_clip() {
  difference() {
    union() {
      translate([0, -clip_w/2, -zf-clip_t]) cube([clip_t+0.6, clip_w, 2*zf+2*clip_t]);          // back
      for (sg=[-1,1]) translate([-clip_reach, -clip_w/2, sg>0 ? zf : -zf-clip_t]) cube([clip_reach+0.6, clip_w, clip_t]);  // arms
      // bumps at the arm tips, with a ramp so it slides on
      for (sg=[-1,1]) translate([-clip_reach, clip_w/2, sg*zf]) rotate([90,0,0]) linear_extrude(clip_w)
        polygon(sg>0 ? [[0,0],[2,0],[0.6,-clip_bump],[0,-clip_bump]] : [[0,0],[2,0],[0.6,clip_bump],[0,clip_bump]]);
    }
  }
}

// ================= gate (side-sliding ladder strip) =================
// Assembly coords for the TOP gate, closed. Push the knob 13.75 mm towards +x to open.
module gate() {
  translate([0, fit/2, 0]) {
    // two rails, outside the coin slot
    for (sg=[-1,1]) translate([-gate_len_half, 0, sg>0 ? rail_z0 : -rail_z1]) cube([2*gate_len_half, gate_t, rail_z1-rail_z0]);
    // seven rungs across the slot, under the middle of each column
    for (c=[0:6]) translate([colx(c)-rung_w/2, 0, -rail_z1+0.01]) cube([rung_w, gate_t, 2*rail_z1-0.02]);
    // knobs, front and back: they poke out through the board's skin
    for (sg=[-1,1]) translate([knob_x, 0, 0]) hull() {
      translate([-1.5, 0, sg>0 ? rail_z1-0.5 : -zf-3.5]) cube([3, gate_t, 4]);
      translate([-3, 0, sg>0 ? zf+1.5 : -zf-3.5]) cube([6, gate_t, 2]);
    }
  }
}

// ================= fixed entry bar with 14 Hall sensors =================
module entry_bar() {
  difference() {
    // chamfered body with softened ends
    translate([-bar_w/2, bar_y0, -bar_z]) multmatrix(M_XZY) rbox([bar_w, 2*bar_z, bar_h], r=1.5, c=0);
    // top chamfers along the long edges
    for (s=[-1,1]) translate([0, bar_y0+bar_h, s*bar_z]) rotate([45,0,0]) cube([bar_w+2, 2*2.5, 2*2.5], center=true);
    for (c=[0:6]) {
      translate([colx(c)-col_w/2, bar_y0-1, -throat/2]) cube([col_w, throat_h+1.01, throat]);
      translate([colx(c)-col_w/2, bar_y0+throat_h, 0]) hull() {
        translate([0,0,-throat/2]) cube([col_w, 0.01, throat]);
        translate([0,bar_h-throat_h+0.01,-funnel_z]) cube([col_w, 0.01, 2*funnel_z]);
      }
      for (s=[-1,1]) translate([colx(c)-a3144[0]/2, sens_y-a3144[1]/2, s>0 ? throat/2+sens_wall : -bar_z-1])
        cube([a3144[0], a3144[1], bar_z - throat/2 - sens_wall + 1]);
      // leg channel: from the sensor pocket straight down into the trench, open to the face
      for (s=[-1,1]) translate([colx(c)-2.3, trench_y0, s>0 ? throat/2+sens_wall : -bar_z-1]) cube([4.6, sens_y-trench_y0, bar_z - throat/2 - sens_wall + 1]);
    }
    // wire trench along the bottom of the front and back faces, open at the right end
    for (s=[-1,1]) translate([-bar_w/2+4, trench_y0, s>0 ? bar_z-trench_d : -bar_z-1]) cube([bar_w, trench_y1-trench_y0, trench_d+1]);
    // hole through the solid right end: the back bundle comes through here to the front
    translate([xhole_x, (trench_y0+trench_y1)/2, -bar_z-1]) cylinder(d=6, h=2*bar_z+2);
    // small bevel on the bottom edges, where the coin leaves the bar
    for (c=[0:6]) translate([colx(c), bar_y0, 0]) rotate([0,0,0]) hull() {
      translate([-col_w/2, -0.01, -throat/2-0.8]) cube([col_w, 0.01, throat+1.6]);
      translate([-col_w/2, 0.8, -throat/2]) cube([col_w, 0.01, throat]);
    }
  }
  // tongues at both ends: they drop into the slots in the uprights' ears
  for (s=[-1,1]) translate([s>0 ? bar_w/2-0.5 : -bar_w/2-tongue_l, bar_y0, -tongue_z]) cube([tongue_l+0.5, tongue_h, 2*tongue_z]);
}

// ================= uprights =================
// Tapered A-profile: wide foot for stability, narrow top; two cut-outs save plastic.
up_top  = bar_y0 + bar_h;
up_wb   = 30;   // half depth at the base
up_wt   = 18;   // half depth at the top
module up_profile() {   // 2D, in (y, z)
  offset(r=4) offset(delta=-4) polygon([[base_y, -up_wb], [up_top, -up_wt], [up_top, up_wt], [base_y, up_wb]]);
}
module up_cutouts() {
  for (band=[[base_y+20, -27], [45, bar_y0-4]]) offset(r=5) offset(delta=-5) intersection() {
    offset(delta=-9) up_profile();
    translate([band[0], -100]) square([band[1]-band[0], 200]);
  }
}
wire_d = 4;   // depth of the cable channels
module wire_path() {   // 6 mm wide channel, 2.5 mm in from the back edge, full height
  intersection() {
    difference() { offset(delta=-2.5) up_profile(); offset(delta=-8.5) up_profile(); }
    translate([base_y-1, -100]) square([up_top-base_y+2, 100-12]);
  }
}
module upright_body(xi, outward) {
  x0 = outward>0 ? xi : xi-up_t;
  difference() {
    translate([x0, 0, 0]) multmatrix(M_YZX) linear_extrude(up_t) up_profile();
    translate([x0-1, 0, 0]) multmatrix(M_YZX) linear_extrude(up_t+2) up_cutouts();
    // cable channel along the back edge of the outer face (sensor wires on the right, servo cable on the left)
    translate([outward>0 ? x0+up_t-wire_d : x0-0.01, 0, 0]) multmatrix(M_YZX) linear_extrude(wire_d+0.01) wire_path();
  }
  ear_x0 = outward>0 ? bar_w/2 : xi;
  ear_x1 = outward>0 ? xi : -bar_w/2;
  difference() {
    translate([ear_x0, bar_y0-4, -10]) cube([ear_x1-ear_x0+0.01, bar_h+2, 20]);
    // slot, open at the top and on the board side: the bar's tongue drops in
    translate([outward>0 ? bar_w/2-1 : -bar_w/2-tongue_l-fit, bar_y0-fit, -tongue_z-fit/2]) cube([tongue_l+fit+1, 100, 2*tongue_z+fit]);
    // right side only: the sensor bundle leaves the front trench through the front cheek...
    if (outward>0) translate([bar_w/2-1, trench_y0, tongue_z]) cube([xi-bar_w/2+2, trench_y1-trench_y0, 7]);
    // lock pin goes through both cheeks, just above the tongue
    translate([outward>0 ? bar_w/2+2.6 : -bar_w/2-2.6, bar_y0+tongue_h+fit+lock_hole/2, -11]) cylinder(d=lock_hole, h=22);
  }
}
module upright_right() {
  difference() {
    union() {
      upright_body(x_right, 1);
      translate([x_right+0.01, 0, 0]) rotate([0,90,0]) cylinder(d=pin_d+8, h=up_t-0.02);   // solid round around the hole
    }
    // ...goes through the upright here, then along a groove on the outer face to the cable channel
    translate([x_right-1, trench_y0, tongue_z+0.5]) cube([up_t+2, trench_y1-trench_y0, 5]);
    translate([x_right+up_t-wire_d, trench_y0, -up_wt]) cube([wire_d+1, trench_y1-trench_y0, up_wt+tongue_z+5.5]);
    // hole for the axle pin: snug, the pin is pushed in from outside
    translate([x_right-1, 0, 0]) rotate([0,90,0]) cylinder(d=pin_d+0.15, h=up_t+2);
    translate([x_right+up_t-0.6, 0, 0]) rotate([0,90,0]) cylinder(d1=pin_d+0.15, d2=pin_d+1.4, h=0.61);
  }
}
module upright_left() {
  sx = x_left - up_t;
  difference() {
    upright_body(x_left, -1);
    translate([sx-1, -servo_spline_off-fit, -servo_w/2-fit]) cube([up_t+2, servo_l+2*fit, servo_w+2*fit]);
    // two slots for the servo strap's snap legs (no screws through the flanges)
    for (sg=[-1,1]) translate([sx-1, servo_yc-strap_w/2-fit, sg>0 ? slot_z0 : -slot_z1]) cube([up_t+2, strap_w+2*fit, slot_z1-slot_z0]);
  }
}

servo_yc = -servo_spline_off + servo_l/2;   // middle of the servo body (y)

// ================= servo strap (print 1) =================
// A U that hugs the bottom of the servo; its two legs go through the slots in the left upright
// and click behind its inner face. Squeeze the two hooks together to take the servo out.
// Local coords = assembly coords.
module servo_strap() {
  xb = sx_out - servo_case_below_flange;          // bottom of the servo case
  translate([0, servo_yc-strap_w/2, 0]) multmatrix(M_XZY) linear_extrude(strap_w) {
    // (x, z) profile
    translate([xb-strap_t, -(strap_z0+strap_t)]) square([strap_t, 2*(strap_z0+strap_t)]);     // bottom beam
    translate([xb-0.4, -6]) square([0.4+0.01, 12]);                                           // pad: presses the servo 0.4 mm
    for (sg=[-1,1]) {
      z_in = strap_z0; z_out = strap_z0+strap_t;
      translate([xb-strap_t, sg>0 ? z_in : -z_out]) square([x_left+2.5-(xb-strap_t), strap_t]);   // leg
      // hook: ramp on the way in, flat face catches the inner face of the upright
      polygon(sg>0 ? [[x_left+0.2, z_out-0.01],[x_left+0.2, z_out+1.2],[x_left+2.5, z_out-0.01]]
                   : [[x_left+0.2, -z_out+0.01],[x_left+0.2, -z_out-1.2],[x_left+2.5, -z_out+0.01]]);
    }
  }
}

// ================= foot socket (print 2) =================
// A frame stuck to the base board (double-sided mounting tape or hot glue). The upright stands
// in it on the base board itself. Same part both sides. Local: upright centred at x=0, z=0.
module foot_socket() {
  difference() {
    union() {
      translate([0,0,0]) linear_extrude(sock_h) offset(r=sock_wall+fit) square([up_t, 2*up_wb], center=true);
      linear_extrude(2) offset(r=sock_wall+sock_fl) square([up_t, 2*up_wb], center=true);
    }
    translate([0,0,-1]) linear_extrude(sock_h+2) offset(delta=fit) square([up_t, 2*up_wb], center=true);
    // notches so the cable channel (back edge, outer face) can leave at the bottom: both sides
    for (sg=[-1,1]) translate([sg*(up_t/2+fit+sock_wall/2), -up_wb+5.5, sock_h/2+2]) cube([sock_wall+2, 7, sock_h], center=true);
  }
}

// ================= small pins =================
module axle_pin() {   // right pivot: pushed through the right upright into the board's right boss
  L = (x_right+up_t) - (board_w/2-2);
  cylinder(d=pin_d+6, h=1.6);                                     // head
  translate([0,0,1.6]) cylinder(d=pin_d, h=L-1);
  translate([0,0,1.6+L-1]) cylinder(d1=pin_d, d2=pin_d-1.6, h=1);
  // three crush ribs for a tight fit in the upright only
  for (a=[0,120,240]) rotate([0,0,a]) translate([pin_d/2-0.2, -0.4, 1.6]) cube([0.45, 0.8, up_t-0.5]);
}
module lock_pin() {   // sensor bar: pushed front-to-back through the ear, above the bar's tongue
  difference() {
    union() {
      cylinder(d=lock_d+3.5, h=1.5);
      translate([0,0,1.5]) cylinder(d=lock_d, h=20.5);
      translate([0,0,22]) cylinder(d1=lock_d, d2=lock_d-1, h=0.8);
    }
  }
}

// ================= small parts =================
module tray() {  // catches the coins when the bottom gate opens
  w = board_w + 2; d = 60; h = 22;
  difference() {
    translate([-w/2, 0, -d/2]) multmatrix(M_XZY) rbox([w, d, h], r=6, c=0);
    translate([-w/2+1.6, 1.6, -d/2+1.6]) multmatrix(M_XZY) rbox([w-3.2, d-3.2, h], r=4.4, c=0);
    // finger notch to pull it out
    translate([0, h, d/2]) rotate([0,0,0]) scale([1,0.6,1]) rotate([0,0,0]) sphere(r=12);
  }
}
module sensor_test() {  // one column of the entry bar + 60 mm of slot: test magnets BEFORE printing the rest
  difference() {
    translate([-col_w/2-5, 0, -bar_z]) cube([col_w+10, 70, 2*bar_z]);
    translate([-col_w/2, -1, -throat/2]) cube([col_w, 80, throat]);
    translate([-col_w/2, 52, 0]) hull() { translate([0,0,-throat/2]) cube([col_w,0.01,throat]); translate([0,18.01,-funnel_z]) cube([col_w,0.01,2*funnel_z]); }
    for (s=[-1,1]) translate([-a3144[0]/2, 40-a3144[1]/2, s>0 ? throat/2+sens_wall : -bar_z-1]) cube([a3144[0], a3144[1], bar_z-throat/2-sens_wall+1]);
    translate([0, 20, -20]) cylinder(d=14, h=40);
    // cut away the bulk at the sides, keep only what guides the coin
    for (s=[-1,1]) translate([s*(col_w/2+5), 26, 0]) cube([6, 36, 2*bar_z+2], center=true);
  }
}

// ================= assembly preview =================
module assembly(angle=0) {
  rotate([angle,0,0]) {
    color("#4a7bd1") { core_half(); rotate([0,180,0]) core_half(); }
    
    color("#e7e7e7") { translate([0, rows_h/2+fit/2, 0]) gate(); mirror([0,1,0]) translate([0, rows_h/2+fit/2, 0]) gate(); }
    for (c=[0:6], r=[0:2]) {
      col = ((c+r)%2==0) ? "#d83b3b" : "#f2c230";
      if (c!=6 || r<1) color(col) translate([colx(c), rowy(r), -coin_t/2]) coin();
    }
  }
  color("#3b3b3b") entry_bar();
  color("#9aa3ad") { upright_left(); upright_right(); }
  color("#2c2c2c") translate([x_left-up_t-28, -servo_spline_off, -servo_w/2]) cube([37, servo_l, servo_w]);
  color("#ffffff") translate([-(board_w/2+boss_l)-2.5, -16, -3]) cube([2.5, 32, 6]);
  color("#c8a06a") translate([-150, base_y-8, -70]) cube([300, 8, 140]);
  color("#bfc6cc") translate([0, base_y, 0]) tray();
}

// ================= print orientations (flat face on the bed) =================
if (part=="assembly") assembly(0);
if (part=="assembly_flip") assembly(90);
if (part=="coin") coin();
if (part=="core_half") translate([0,0,zf]) rotate([180,0,0]) core_half();
if (part=="gate") rotate([90,0,0]) translate([0,-fit/2,0]) gate();
if (part=="entry_bar") translate([0,0,-bar_y0]) rotate([90,0,0]) entry_bar();
if (part=="upright_left") translate([0,0,-(x_left-up_t)]) rotate([0,-90,0]) upright_left();
if (part=="upright_right") translate([0,0,x_right+up_t]) rotate([0,90,0]) upright_right();
if (part=="board_clip") translate([0,0,clip_w/2]) rotate([90,0,0]) board_clip();
if (part=="servo_strap") translate([0,0,-(servo_yc-strap_w/2)]) rotate([90,0,0]) servo_strap();
if (part=="foot_socket") foot_socket();
if (part=="axle_pin") axle_pin();
if (part=="lock_pin") lock_pin();
if (part=="tray") rotate([90,0,0]) tray();
if (part=="sensor_test") rotate([90,0,0]) sensor_test();

// pieces in assembly position, for the 3D viewer and the assembly guide
module m3(len, head=true) { cylinder(d=3, h=len); if (head) translate([0,0,-2.8]) cylinder(d=5.5, h=2.8); }
module nut() { cylinder(d=6.2, h=2.4, $fn=6); }
sx_out = x_left - up_t;   // outer face of the left upright = servo flange plane
if (part=="g_servo") {
  translate([sx_out - servo_case_below_flange, -servo_spline_off, -servo_w/2]) cube([servo_case_below_flange + servo_case_above_flange, servo_l, servo_w]);
  translate([sx_out - 2.5, -servo_spline_off - 7, -servo_w/2]) difference() {
    cube([2.5, servo_l + 14, servo_w]);
    for (yy=[servo_l/2 - servo_hole_pitch/2 + 7, servo_l/2 + servo_hole_pitch/2 + 7], zz=[servo_w/2-servo_hole_gap/2, servo_w/2+servo_hole_gap/2]) translate([-1,yy,zz]) rotate([0,90,0]) cylinder(d=3, h=5);
  }
  translate([sx_out + servo_case_above_flange, 0, 0]) rotate([0,90,0]) cylinder(d=12, h=1.5);
  // 3-wire cable leaves the far end of the case, low down
  translate([sx_out - servo_case_below_flange + 3, -servo_spline_off + servo_l - 1, -2.5]) cube([4, 25, 5]);
  translate([sx_out + servo_case_above_flange, 0, 0]) rotate([0,90,0]) cylinder(d=5.8, h=horn_x - horn_t - sx_out - servo_case_above_flange + 1);
}
if (part=="g_horn") {
  translate([horn_x, 0, 0]) rotate([0,-90,0]) { linear_extrude(horn_t) horn_outline(0); cylinder(d=horn_hub_d-1, h=horn_hub_h); }
}
if (part=="g_horn_screw") translate([horn_x, 0, 0]) rotate([0,-90,0]) translate([0,0,0]) m3(6);
if (part=="g_strap") servo_strap();
if (part=="g_core_front") core_half();
if (part=="g_core_back") rotate([0,180,0]) core_half();   // the same print, turned over
if (part=="g_clips") for (sg=[-1,1], e=[-1,1]) translate([sg*board_w/2, e*clip_y, 0]) mirror([sg>0?0:1,0,0]) board_clip();
if (part=="g_gate_top") translate([0, rows_h/2, 0]) gate();
if (part=="g_gate_bot") rotate([180,0,0]) translate([0, rows_h/2, 0]) gate();
if (part=="g_magnets") for (c=[0:6], r=[0:2]) if (c!=6 || r<1) translate([colx(c), rowy(r), coin_t/2-mag_h]) cylinder(d=mag_d, h=mag_h);
if (part=="g_red")    for (c=[0:6], r=[0:2]) if ((c+r)%2==0 && (c!=6 || r<1)) translate([colx(c), rowy(r), -coin_t/2]) coin();
if (part=="g_yellow") for (c=[0:6], r=[0:2]) if ((c+r)%2==1 && (c!=6 || r<1)) translate([colx(c), rowy(r), -coin_t/2]) coin();
if (part=="g_upl") upright_left();
if (part=="g_upr") upright_right();
if (part=="g_sock_l") translate([x_left-up_t/2, base_y, 0]) multmatrix(M_XZY) foot_socket();
if (part=="g_sock_r") translate([x_right+up_t/2, base_y, 0]) multmatrix(M_XZY) foot_socket();
if (part=="g_axle_pin") translate([x_right+up_t, 0, 0]) rotate([0,-90,0]) axle_pin();
if (part=="g_bar") entry_bar();
if (part=="g_sensors") for (c=[0:6], sg=[-1,1]) {
  zf0 = throat/2+sens_wall;   // branded face sits here, against the thin wall
  translate([colx(c), 0, 0]) mirror([0,0,sg>0?0:1]) {
    translate([-2, sens_y-1.5, zf0]) cube([4, 3, 1.5]);                                    // A3144 body
    for (k=[-1,0,1]) translate([k*1.27, 0, 0]) {
      translate([-0.2, (trench_y0+trench_y1)/2, zf0+0.55]) cube([0.4, sens_y-1.5-(trench_y0+trench_y1)/2, 0.4]);   // leg down
      translate([-0.2, (trench_y0+trench_y1)/2, zf0+0.55]) cube([0.4, 0.4, bar_z-trench_d/2-zf0-0.55]);          // bent out into the trench
    }
  }
}
if (part=="g_lock_pins") for (sg=[-1,1]) translate([sg*(bar_w/2+2.6), bar_y0+tongue_h+fit+lock_hole/2, -10-1.5]) lock_pin();
if (part=="g_base") translate([-150, base_y-9, base_d1]) cube([300, 9, base_d0-base_d1]);
if (part=="g_breadboard") translate([bb_pos[0], base_y, bb_pos[1]]) difference() {
  cube(bb);
  translate([4, bb[1]-0.6, bb[2]/2-1.5]) cube([bb[0]-8, 1, 3]);                       // centre channel
  for (i=[0:62], j=[0:4], k=[0,1]) translate([5+i*2.54, bb[1]-0.8, 7+j*2.54+k*(bb[2]-14-4*2.54)]) cube([1,1,1]);
}
if (part=="g_battery") translate([batt[0], base_y, batt[1]]) cube([batt[2], batt[4], batt[3]]);
if (part=="g_esp32") translate([esp_pos[0], base_y+bb[1]+8.5, esp_pos[1]]) {   // plugged straight into the breadboard
  translate([-esp_l/2, 0, -esp_w/2]) cube([esp_l, esp_pcb, esp_w]);                    // PCB
  translate([esp_l/2-26.5, esp_pcb, -9]) cube([25.5, 3.2, 18]);                         // WROOM module (antenna end at +x)
  translate([-esp_l/2-1, esp_pcb, -4]) cube([6.5, 3, 8]);                               // micro-USB, facing the left edge
  for (sg=[-1,1]) translate([-esp_l/2+6, -8.5, sg*12.7-1.25]) cube([15*2.54, 8.5, 2.5]);    // pin headers, into the breadboard
}
if (part=="g_tray") translate([0, base_y, 0]) tray();
if (part=="asm_core") { core_half(); rotate([0,180,0]) core_half(); }
if (part=="asm_red")    for (c=[0:6], r=[0:2]) if ((c+r)%2==0 && (c!=6 || r<1)) translate([colx(c), rowy(r), -coin_t/2]) coin();
if (part=="asm_yellow") for (c=[0:6], r=[0:2]) if ((c+r)%2==1 && (c!=6 || r<1)) translate([colx(c), rowy(r), -coin_t/2]) coin();
if (part=="asm_bar") entry_bar();
if (part=="asm_uprights") { upright_left(); upright_right(); }
if (part=="asm_servo") { translate([x_left-up_t-28, -servo_spline_off, -servo_w/2]) cube([37, servo_l, servo_w]); translate([-(board_w/2+boss_l)-2.5, -16, -3]) cube([2.5, 32, 6]); }
if (part=="asm_base") { translate([-150, base_y-8, -70]) cube([300, 8, 140]); translate([0, base_y, 0]) tray();
  for (s=[-1,1], zz=[-1,1]) translate([s>0 ? x_right+up_t : x_left-up_t, base_y, zz*up_z]) rotate([0, s>0?0:90, 0]) mirror([0,0,zz>0?1:0]) translate([0,0,0]) cube([s>0?20:3, 3, 3]); }
if (part=="asm_sensors") for (c=[0:6], s=[-1,1]) translate([colx(c)-2, sens_y-1.5, s>0 ? throat/2+sens_wall : -throat/2-sens_wall-1.5]) cube([4,3,1.5]);

