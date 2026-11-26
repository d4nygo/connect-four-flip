# CAD

`flip_board.scad`: parametric OpenSCAD model of the flip board and stand (concept v0, 24 Nov 2026). Untested on hardware.

Export a part: `openscad -D 'part="core_half"' -o core_half.stl flip_board.scad`
Parts: coin, core_half, gate, entry_bar, upright_left, upright_right, bracket, tray, sensor_test.

STL exports are not kept in git (big binary files); they are in the project files folder `flip-board-cad/`. Explanation: `docs/03-hardware.md` → "3D-printable stand, concept v0".
