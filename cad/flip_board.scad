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
win_d   = 18;                    // round windows to see the coins

gate_t  = 3.0;  groove = gate_t + fit;   // gate plate thickness and its groove
gate_L  = 16;                    // gate plate depth (z)
gate_shift = ch/2 + gate_L/2;    // 11: push this far either way to open
gate_x  = inner_w/2 - 0.1;       // gate half length (x)
mag_z   = 5.5;                   // detent magnets sit at z = +-5.5 (outside the slot)
tab_w   = 20; tab_z = 30;        // gate pull tabs reach z = +-30

// sweep circle of the turning board (corners of the end caps)
R_sweep = sqrt(pow(board_h/2,2) + pow(cap_z,2));   // ~86.6
bar_y0  = ceil(R_sweep + 3);     // bottom of the fixed entry bar (3 mm clearance)
bar_h   = 26;  bar_z = 9.5;  bar_w = 210;  funnel_z = 7.5;
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

// ================= board core: two identical halves =================
// Assembly coords for the FRONT half (z >= 0). The back half is the same part turned over.
module boss_shape() {   // rounded axle boss, profile in y-z, extruded along x
  multmatrix(M_YZX) linear_extrude(boss_l) translate([-boss_y, -zf]) rr2(2*boss_y, 2*zf, 4);
}
module core_half() {
  difference() {
    union() {
      translate([-board_w/2, -rows_h/2, ch/2]) cube([board_w, rows_h, plate]);
      for (s=[-1,1]) translate([s>0 ? inner_w/2 : -board_w/2, -rows_h/2, 0]) cube([side, rows_h, zf]);
      for (c=[0:5]) translate([colx(c)+col_w/2, -rows_h/2, 0]) cube([rib, rows_h, ch/2]);
      for (s=[-1,1]) intersection() {
        translate([s>0 ? board_w/2-0.01 : -board_w/2-boss_l+0.01, 0, 0]) boss_shape();
        translate([-200, -50, 0]) cube([400, 100, zf]);
      }
    }
    // windows with a chamfered rim on the outside
    for (c=[0:6], r=[0:5]) translate([colx(c), rowy(r), 0]) {
      cylinder(d=win_d, h=20);
      translate([0,0,zf-edge_c]) cylinder(d1=win_d, d2=win_d+2*edge_c+0.2, h=edge_c+0.01);
    }
    // chamfer along the two long outer edges
    for (s=[-1,1]) translate([s*board_w/2, 0, zf]) rotate([0,45,0]) cube([2*edge_c, 300, 2*edge_c], center=true);
    // axle hole: right side takes the upright's pin, left side clears the horn screw head
    for (s=[-1,1]) translate([s*(board_w/2+boss_l+1), 0, 0]) rotate([0,90,0])
      translate([0,0,s>0 ? -(boss_l+1+3) : -1]) cylinder(d=pin_d+0.6, h=boss_l+1+3);
    // lead-in chamfer on the pin hole
    translate([board_w/2+boss_l+0.01, 0, 0]) rotate([0,-90,0]) cylinder(d1=pin_d+2.6, d2=pin_d+0.6, h=1);
    // horn screw holes (drill out with 1.5-2 mm to match your horn)
    for (s=[-1,1], yy=[-14,-10.5,-7,7,10.5,14]) translate([s*(board_w/2+boss_l+1), yy, 0]) rotate([0,90,0])
      translate([0,0,-8]) cylinder(d=1.6, h=16);
    // M3 bolts joining the two halves, with a recess for the head / nut
    for (s=[-1,1], yy=[-50,-20,20,50]) translate([s*(inner_w/2+side/2), yy, -1]) {
      cylinder(d=3.3, h=20);
      translate([0,0,1+zf-1.6]) cylinder(d=6.4, h=5, $fn=6);
    }
    // pilot holes for the end cap screws
    for (s=[-1,1], e=[-1,1]) translate([s*(inner_w/2+side/2), e*(rows_h/2-10), 0]) rotate([e*-90,0,0]) cylinder(d=2.5, h=11);
  }
}

// ================= end cap with the gate groove =================
// Assembly coords for the TOP cap (y from rows_h/2 to board_h/2).
module end_cap() {
  difference() {
    // rounded corners where the board sweeps past the sensor bar, chamfered outer edges
    translate([-board_w/2, rows_h/2, -cap_z]) multmatrix(M_XZY) rbox([board_w, 2*cap_z, cap_h], r=5, c=edge_c);
    for (c=[0:6]) {
      translate([colx(c)-col_w/2, 0, -ch/2]) cube([col_w, 200, ch]);
      // funnel lead-in on the outer face: the coin finds the slot even if it drops a bit off-line
      translate([colx(c), board_h/2+0.01, 0]) hull() {
        translate([-col_w/2, -0.01, -ch/2]) cube([col_w, 0.01, ch]);
        translate([-col_w/2-1, -2.5, -ch/2]) cube([col_w+2, 0.01, ch]);
        translate([-col_w/2-1, 0, -ch/2-2]) cube([col_w+2, 0.01, ch+4]);
        translate([-col_w/2, -2.5, -ch/2]) cube([col_w, 2.5, ch]);
      }
    }
    translate([-(gate_x+fit), rows_h/2-1, -50]) cube([2*(gate_x+fit), groove+1, 100]);
    for (zz=[-mag_z, mag_z]) translate([0, rows_h/2+groove-0.01, zz]) rotate([-90,0,0]) cylinder(d=mag_d+fit, h=mag_h+0.1);
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
      // plate, with chamfered sliding edges so it doesn't catch on the slot
      hull() {
        translate([-gate_x, 0.5, -gate_L/2]) cube([2*gate_x, gate_t-1, gate_L]);
        translate([-gate_x, 0, -gate_L/2+0.6]) cube([2*gate_x, gate_t, gate_L-1.2]);
      }
      // rounded pull tabs, both faces
      translate([0, gate_t, 0]) rotate([90,0,0]) linear_extrude(gate_t) translate([-tab_w/2, -tab_z]) rr2(tab_w, 2*tab_z, 4);
      // finger lips at the tab ends, rounded, pointing away from the board
      for (s=[-1,1]) translate([0, 0, s*(tab_z-1.5)]) hull() {
        translate([-tab_w/2+3, 0, -1.5]) cube([tab_w-6, gate_t+4, 3]);
        translate([-tab_w/2, 0, -1.5]) cube([tab_w, gate_t, 3]);
      }
    }
    translate([0, gate_t+0.01, mag_z]) rotate([90,0,0]) cylinder(d=mag_d+fit, h=mag_h+0.1);
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
      for (s=[-1,1]) translate([colx(c)-2.5, bar_y0-1, s>0 ? bar_z-1.5 : -bar_z-1]) cube([5, sens_y-bar_y0+1, 2.5]);
    }
    for (s=[-1,1]) translate([-bar_w/2-1, bar_y0-0.01, s>0 ? bar_z-1.5 : -bar_z-1]) cube([bar_w+2, 4, 2.5]);
    // small bevel on the bottom edges, where the coin leaves the bar
    for (c=[0:6]) translate([colx(c), bar_y0, 0]) rotate([0,0,0]) hull() {
      translate([-col_w/2, -0.01, -throat/2-0.8]) cube([col_w, 0.01, throat+1.6]);
      translate([-col_w/2, 0.8, -throat/2]) cube([col_w, 0.01, throat]);
    }
    for (s=[-1,1], yy=[bar_y0+7, bar_y0+21]) translate([s*(bar_w/2+1), yy, 0]) rotate([0,90,0]) translate([0,0,-12]) cylinder(d=2.5, h=12);
  }
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
module upright_body(xi, outward) {
  x0 = outward>0 ? xi : xi-up_t;
  difference() {
    translate([x0, 0, 0]) multmatrix(M_YZX) linear_extrude(up_t) up_profile();
    translate([x0-1, 0, 0]) multmatrix(M_YZX) linear_extrude(up_t+2) up_cutouts();
  }
  ear_x0 = outward>0 ? bar_w/2 : xi;
  ear_x1 = outward>0 ? xi : -bar_w/2;
  translate([ear_x0, bar_y0+2, -10]) cube([ear_x1-ear_x0+0.01, bar_h-4, 20]);
}
module upright_right() {
  difference() {
    union() {
      upright_body(x_right, 1);
      translate([x_right+0.01, 0, 0]) rotate([0,-90,0]) {
        cylinder(d=pin_d, h=x_right-(board_w/2-2));
        cylinder(d1=pin_d+4, d2=pin_d, h=2);          // fillet at the root: stronger pin
      }
    }
    // chamfered pin tip
    translate([board_w/2-2-0.01, 0, 0]) rotate([0,90,0]) difference() { cylinder(d=pin_d+2, h=1); cylinder(d1=pin_d-1.6, d2=pin_d, h=1); }
    for (yy=[bar_y0+7, bar_y0+21]) translate([bar_w/2-1, yy, 0]) rotate([0,90,0]) cylinder(d=3.3, h=40);
    for (zz=[-14,14]) translate([x_right-1, base_y+8, zz]) rotate([0,90,0]) cylinder(d=3.3, h=20);
  }
}
module upright_left() {
  sx = x_left - up_t;
  difference() {
    upright_body(x_left, -1);
    translate([sx-1, -servo_spline_off-fit, -servo_w/2-fit]) cube([up_t+2, servo_l+2*fit, servo_w+2*fit]);
    for (yy=[-servo_spline_off+servo_l/2-servo_hole_pitch/2, -servo_spline_off+servo_l/2+servo_hole_pitch/2], zz=[-servo_hole_gap/2, servo_hole_gap/2])
      translate([sx-1, yy, zz]) rotate([0,90,0]) cylinder(d=2.8, h=up_t+2);
    for (yy=[bar_y0+7, bar_y0+21]) translate([-bar_w/2-40, yy, 0]) rotate([0,90,0]) cylinder(d=3.3, h=41);
    for (zz=[-14,14]) translate([sx-1, base_y+8, zz]) rotate([0,90,0]) cylinder(d=3.3, h=20);
  }
}

// ================= small parts =================
module bracket() {  // L-bracket with a gusset: upright to base board (print 4)
  difference() {
    union() {
      cube([20, 3, 40]); cube([3, 20, 40]);
      translate([0,0,17]) linear_extrude(6) polygon([[0,0],[18,0],[0,18]]);   // gusset
    }
    for (zz=[9,31]) { translate([11,-1,zz]) rotate([-90,0,0]) cylinder(d=3.3, h=5); translate([-1,11,zz]) rotate([0,90,0]) cylinder(d=3.3, h=5); }
  }
}
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

