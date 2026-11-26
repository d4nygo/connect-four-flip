# CAD

`flip_board.scad`: parametric OpenSCAD model of the flip board and stand (concept v0, 24 Nov 2026). Untested on hardware.

Export a part: `openscad -D 'part="core_half"' -o core_half.stl flip_board.scad`
Parts (v2, no screws): coin, core_half, gate, board_clip, entry_bar, lock_pin, upright_left, upright_right, axle_pin, servo_strap, foot_socket, tray, sensor_test.

STL exports are not kept in git (big binary files); they are in the project files folder `flip-board-cad/`. Explanation: `docs/03-hardware.md` → "3D-printable stand, concept v0".
