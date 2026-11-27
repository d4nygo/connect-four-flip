# CAD

`flip_board.scad`: parametric OpenSCAD model of the flip board and stand (concept v0, 24 Nov 2026). Untested on hardware.

Export a part: `openscad -D 'part="core_half"' -o core_half.stl flip_board.scad`
Parts (v2, no screws): coin, core_half, gate, board_clip, entry_bar, lock_pin, upright_left, upright_right, axle_pin, servo_strap, foot_socket, tray, sensor_test.

**Kept in git since 27 Nov 2026 (Danny's call):**

- `stl/`: the 13 print-ready STLs for v2.1, each already in its print orientation.
- `print-runs/run0.3mf` … `run5.3mf`: the whole print plan as ready plates (220 × 220 mm bed, parts placed, per-object infill). Open one in PrusaSlicer, pick your printer profile, slice. Run 0 = sensor test piece + 1 test coin (2 h 37 min), then runs 1–5 (about 48.5 h, 491 g PLA). `plates.json` lists every part's position.
- `tools/`: the scripts that made the plates. From the repo root: `python3 cad/tools/pack_runs.py` (packs the STLs into runs, needs `trimesh shapely scipy`), then `python3 cad/tools/make_3mf.py` (writes the 3MFs). `gcode_to_layers.py` turns sliced G-code into the layer preview data used by the review page.

The full design review page (simulation, fit check, wiring, print runs, assembly steps) is a single offline file: `docs/design-review/flip-board-design-review.html`. Explanation: `docs/03-hardware.md` → "3D-printable stand, concept v0".
