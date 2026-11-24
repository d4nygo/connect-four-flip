// Connect Four Flip: parametric 3D-printable board, draft v0 (2026-11-24)
// Untested on hardware. Measure your real parts and change the numbers below.
//
// Pick a part:  openscad -D 'part="coin"' -o coin.stl flip_board.scad
// Parts: coin, core_half, end_cap, gate, entry_bar, upright_left, upright_right,
//        bracket, tray, sensor_test, assembly (preview only)
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
servo_spline_off = 10.2; // spline centre to the near end of the body
servo_flange_to_horn = 16.5; // flange top surface to the outer face of the 2-arm horn

// ---------- derived board numbers ----------
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
cap_z   = 14;                    // end cap half depth (z), guides the gate
board_h = rows_h + 2*cap_h;      // 171
boss_l  = 6;  boss_y = 15;       // axle bosses on both sides
win_d   = 16;                    // round windows to see the coins

gate_t  = 3.0;  groove = gate_t + fit;   // gate plate thickness and its groove
gate_L  = 16;                    // gate plate depth (z)
gate_shift = ch/2 + gate_L/2;    // 11: push this far either way to open
gate_x  = inner_w/2 - 0.1;       // gate half length (x)
mag_z   = 5.5;                   // detent magnets sit at z = +-5.5 (outside the slot)
tab_w   = 20; tab_z = 30;        // gate pull tabs reach z = +-30

// sweep circle of the turning board (corners of the end caps)
R_sweep = sqrt(pow(board_h/2,2) + pow(cap_z,2));   // ~86.6
bar_y0  = ceil(R_sweep + 3);     // bottom of the fixed entry bar (3 mm clearance)
bar_h   = 28;  bar_z = 12;  bar_w = 210;
throat  = coin_t + 0.6;          // slot at the sensors: coin can't wander away from them
throat_h = 16;
sens_wall = 0.8;                 // plastic between sensor face and coin: keep it thin!
sens_y  = bar_y0 + 8;            // sensor height
a3144   = [4.5, 3.6, 1.9];       // pocket for the A3144 body (x, y, z)

base_y  = -(ceil(R_sweep) + 3 + 25);   // top of the base board (-115)
up_t    = 8;  up_z = 22;                // upright thickness and half depth
x_right = board_w/2 + boss_l + 3;       // inner face of right upright
x_left  = -(board_w/2 + boss_l + (servo_flange_to_horn - up_t)); // inner face of left upright
pin_d   = 8;

function colx(c) = (c-3)*pitch;
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

// ================= board core: two identical halves =================
// Assembly coords for the FRONT half (z >= 0). The back half is the same part turned over.
module core_half() {
  difference() {
    union() {
      // plate
      translate([-board_w/2, -rows_h/2, ch/2]) cube([board_w, rows_h, plate]);
      // side walls
      for (s=[-1,1]) translate([s>0 ? inner_w/2 : -board_w/2, -rows_h/2, 0]) cube([side, rows_h, zf]);
      // ribs between columns
      for (c=[0:5]) translate([colx(c)+col_w/2, -rows_h/2, 0]) cube([rib, rows_h, ch/2]);
      // axle bosses
      for (s=[-1,1]) translate([s>0 ? board_w/2 : -board_w/2-boss_l, -boss_y, 0]) cube([boss_l, 2*boss_y, zf]);
    }
    // windows
    for (c=[0:6], r=[0:5]) translate([colx(c), rowy(r), 0]) cylinder(d=win_d, h=20);
    // axle hole (both sides: right side takes the upright's pin, left side the horn screw head)
    for (s=[-1,1]) translate([s*(board_w/2+boss_l+1), 0, 0]) rotate([0,90,0])
      translate([0,0,s>0 ? -(boss_l+1+3) : -1]) cylinder(d=pin_d+0.6, h=boss_l+1+3);
    // horn screw holes (drill out with 1.5-2 mm to match your horn)
    for (s=[-1,1], yy=[-14,-10.5,-7,7,10.5,14]) translate([s*(board_w/2+boss_l+1), yy, 0]) rotate([0,90,0])
      translate([0,0,-8]) cylinder(d=1.6, h=16);
    // M3 bolts joining the two halves
    for (s=[-1,1], yy=[-50,-20,20,50]) translate([s*(inner_w/2+side/2), yy, -1]) cylinder(d=3.3, h=20);
    // pilot holes for the end cap screws
    for (s=[-1,1], e=[-1,1]) translate([s*(inner_w/2+side/2), e*(rows_h/2-10), 0]) rotate([e*-90,0,0]) cylinder(d=2.5, h=11);
  }
}

// ================= end cap with the gate groove =================
// Assembly coords for the TOP cap (y from rows_h/2 to board_h/2).
module end_cap() {
  difference() {
    translate([-board_w/2, rows_h/2, -cap_z]) cube([board_w, cap_h, 2*cap_z]);
    // coin tunnels
    for (c=[0:6]) translate([colx(c)-col_w/2, 0, -ch/2]) cube([col_w, 200, ch]);
    // gate groove on the inner face, open at front and back
    translate([-(gate_x+fit), rows_h/2-1, -50]) cube([2*(gate_x+fit), groove+1, 100]);
    // detent magnets in the groove floor (z = +-5.5, middle of the board)
    for (zz=[-mag_z, mag_z]) translate([0, rows_h/2+groove-0.01, zz]) rotate([-90,0,0]) cylinder(d=mag_d+fit, h=mag_h+0.1);
    // screws into the core side walls
    for (s=[-1,1]) translate([s*(inner_w/2+side/2), 0, 0]) rotate([-90,0,0]) {
      cylinder(d=3.3, h=200);
      translate([0,0,board_h/2-3]) cylinder(d=6.2, h=10);
    }
  }
}

// ================= gate (sliding plate) =================
// Centred = closed (a magnet clicks it in place). Push either tab 11 mm = open.
module gate() {
  difference() {
    union() {
      translate([-gate_x, 0, -gate_L/2]) cube([2*gate_x, gate_t, gate_L]);
      // pull tabs, both faces
      translate([-tab_w/2, 0, -tab_z]) cube([tab_w, gate_t, 2*tab_z]);
      // finger lips at the tab ends (point away from the board)
      for (s=[-1,1]) translate([-tab_w/2, 0, s>0 ? tab_z-3 : -tab_z]) cube([tab_w, gate_t+4, 3]);
    }
    // one detent magnet, on the outer face (towards the cap floor)
    translate([0, gate_t+0.01, mag_z]) rotate([90,0,0]) cylinder(d=mag_d+fit, h=mag_h+0.1);
  }
}

// ================= fixed entry bar with 14 Hall sensors =================
module entry_bar() {
  difference() {
    translate([-bar_w/2, bar_y0, -bar_z]) cube([bar_w, bar_h, 2*bar_z]);
    for (c=[0:6]) {
      // narrow throat at the sensors
      translate([colx(c)-col_w/2, bar_y0-1, -throat/2]) cube([col_w, throat_h+1.01, throat]);
      // funnel above it, wider in z
      translate([colx(c)-col_w/2, bar_y0+throat_h, 0]) hull() {
        translate([0,0,-throat/2]) cube([col_w, 0.01, throat]);
        translate([0,bar_h-throat_h+0.01,-9]) cube([col_w, 0.01, 18]);
      }
      // sensor slots: one in the front wall, one in the back wall, branded face towards the coin
      for (s=[-1,1]) translate([colx(c)-a3144[0]/2, sens_y-a3144[1]/2, s>0 ? throat/2+sens_wall : -bar_z-1])
        cube([a3144[0], a3144[1], bar_z - throat/2 - sens_wall + 1]);
      // groove for the 3 legs + wires along the outer face
      for (s=[-1,1]) translate([colx(c)-2.5, bar_y0-1, s>0 ? bar_z-1.5 : -bar_z-1]) cube([5, sens_y-bar_y0+1, 2.5]);
    }
    // wire channel along the front and back faces, low down
    for (s=[-1,1]) translate([-bar_w/2-1, bar_y0-0.01, s>0 ? bar_z-1.5 : -bar_z-1]) cube([bar_w+2, 4, 2.5]);
    // mounting holes into the upright ears
    for (s=[-1,1], yy=[bar_y0+7, bar_y0+21]) translate([s*(bar_w/2+1), yy, 0]) rotate([0,90,0]) translate([0,0,-12]) cylinder(d=2.5, h=12);
  }
}

// ================= uprights =================
module upright_plate(xi, outward) {   // xi = inner face x, outward = -1 (left) or +1 (right)
  top = bar_y0 + bar_h;
  translate([outward>0 ? xi : xi-up_t, base_y, -up_z]) cube([up_t, top-base_y, 2*up_z]);
  // ear that holds the entry bar end
  ear_x0 = outward>0 ? bar_w/2 : xi;
  ear_x1 = outward>0 ? xi : -bar_w/2;
  difference() {
    translate([ear_x0 - (outward>0?0:0), bar_y0+2, -10]) cube([ear_x1-ear_x0+0.01, bar_h-4, 20]);
  }
}
module upright_right() {
  difference() {
    union() {
      upright_plate(x_right, 1);
      // the right pivot pin (prints standing up, so it is strong)
      translate([x_right+0.01, 0, 0]) rotate([0,-90,0]) cylinder(d=pin_d, h=x_right-(board_w/2-2));
    }
    for (yy=[bar_y0+7, bar_y0+21]) translate([bar_w/2-1, yy, 0]) rotate([0,90,0]) cylinder(d=3.3, h=40);
    for (zz=[-14,14]) translate([x_right-1, base_y+8, zz]) rotate([0,90,0]) cylinder(d=3.3, h=20);
  }
}
module upright_left() {
  sx = x_left - up_t;   // outer face
  difference() {
    upright_plate(x_left, -1);
    // window for the servo body; spline lands on the axle (y=0, z=0)
    translate([sx-1, -servo_spline_off, -servo_w/2-fit]) cube([up_t+2, servo_l+2*fit, servo_w+2*fit]);
    // flange screws
    for (yy=[-servo_spline_off+servo_l/2-servo_hole_pitch/2, -servo_spline_off+servo_l/2+servo_hole_pitch/2], zz=[-servo_hole_gap/2, servo_hole_gap/2])
      translate([sx-1, yy, zz]) rotate([0,90,0]) cylinder(d=2.8, h=up_t+2);
    for (yy=[bar_y0+7, bar_y0+21]) translate([-bar_w/2-40, yy, 0]) rotate([0,90,0]) cylinder(d=3.3, h=41);
    for (zz=[-14,14]) translate([sx-1, base_y+8, zz]) rotate([0,90,0]) cylinder(d=3.3, h=20);
  }
}

// ================= small parts =================
module bracket() {  // L-bracket: upright to base board (print 4)
  difference() {
    union() { cube([20, 3, 40]); cube([3, 20, 40]); }
    for (zz=[10,30]) { translate([10,-1,zz]) rotate([-90,0,0]) cylinder(d=3.3, h=5); translate([-1,10,zz]) rotate([0,90,0]) cylinder(d=3.3, h=5); }
  }
}
module tray() {  // catches the coins when the bottom gate opens
  w = board_w + 2; d = 60; h = 22;
  difference() {
    translate([-w/2, 0, -d/2]) cube([w, h, d]);
    translate([-w/2+2, 2, -d/2+2]) cube([w-4, h, d-4]);
  }
}
module sensor_test() {  // one column of the entry bar + 60 mm of slot: test magnets BEFORE printing the rest
  difference() {
    translate([-col_w/2-6, 0, -bar_z]) cube([col_w+12, 75, 2*bar_z]);
    translate([-col_w/2, -1, -throat/2]) cube([col_w, 80, throat]);
    translate([-col_w/2, 55, 0]) hull() { translate([0,0,-throat/2]) cube([col_w,0.01,throat]); translate([0,21,-9]) cube([col_w,0.01,18]); }
    for (s=[-1,1]) translate([-a3144[0]/2, 40-a3144[1]/2, s>0 ? throat/2+sens_wall : -bar_z-1]) cube([a3144[0], a3144[1], bar_z-throat/2-sens_wall+1]);
    // window to watch the coin
    translate([0, 20, -20]) cylinder(d=14, h=40);
  }
}

// ================= assembly preview =================
module assembly(angle=0) {
  rotate([angle,0,0]) {
    color("#4a7bd1") { core_half(); mirror([0,0,1]) core_half(); }
    color("#6f9be0") { end_cap(); mirror([0,1,0]) end_cap(); }
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
if (part=="end_cap") translate([0,0,board_h/2]) rotate([-90,0,0]) end_cap();
if (part=="gate") rotate([90,0,0]) gate();
if (part=="entry_bar") translate([0,0,-bar_y0]) rotate([90,0,0]) entry_bar();
if (part=="upright_left") translate([0,0,-(x_left-up_t)]) rotate([0,-90,0]) upright_left();
if (part=="upright_right") translate([0,0,x_right+up_t]) rotate([0,90,0]) upright_right();
if (part=="bracket") bracket();
if (part=="tray") rotate([90,0,0]) tray();
if (part=="sensor_test") rotate([90,0,0]) sensor_test();

// pieces in assembly position, for the 3D viewer
if (part=="asm_core") { core_half(); mirror([0,0,1]) core_half(); }
if (part=="asm_caps") { end_cap(); mirror([0,1,0]) end_cap(); }
if (part=="asm_gates") { translate([0, rows_h/2+fit/2, 0]) gate(); mirror([0,1,0]) translate([0, rows_h/2+fit/2, 0]) gate(); }
if (part=="asm_red")    for (c=[0:6], r=[0:2]) if ((c+r)%2==0 && (c!=6 || r<1)) translate([colx(c), rowy(r), -coin_t/2]) coin();
if (part=="asm_yellow") for (c=[0:6], r=[0:2]) if ((c+r)%2==1 && (c!=6 || r<1)) translate([colx(c), rowy(r), -coin_t/2]) coin();
if (part=="asm_bar") entry_bar();
if (part=="asm_uprights") { upright_left(); upright_right(); }
if (part=="asm_servo") { translate([x_left-up_t-28, -servo_spline_off, -servo_w/2]) cube([37, servo_l, servo_w]); translate([-(board_w/2+boss_l)-2.5, -16, -3]) cube([2.5, 32, 6]); }
if (part=="asm_base") { translate([-150, base_y-8, -70]) cube([300, 8, 140]); translate([0, base_y, 0]) tray();
  for (s=[-1,1], zz=[-1,1]) translate([s>0 ? x_right+up_t : x_left-up_t, base_y, zz*up_z]) rotate([0, s>0?0:90, 0]) mirror([0,0,zz>0?1:0]) translate([0,0,0]) cube([s>0?20:3, 3, 3]); }
if (part=="asm_sensors") for (c=[0:6], s=[-1,1]) translate([colx(c)-2, sens_y-1.5, s>0 ? throat/2+sens_wall : -throat/2-sens_wall-1.5]) cube([4,3,1.5]);

