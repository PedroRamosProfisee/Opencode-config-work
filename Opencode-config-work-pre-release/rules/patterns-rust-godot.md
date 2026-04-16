# Rust+Godot Portfolio Learned Patterns

> Loaded only in Rust+Godot workspace sessions. Split from learned-patterns.md on 2026-04-10.

## Architecture

- All domain sims follow Rust-owns-state / Godot-renders — Rust exports flat `#[repr(C)]` snapshots over C ABI; Godot is a pure renderer with no physics or simulation logic
- FFI handle pattern: opaque `SimHandle` heap-allocated via `Box::into_raw`, caller holds `*mut SimHandle` as `IntPtr`, freed via `sim_destroy`
- All domain FFI functions use `#[no_mangle]` (edition 2021); `#[unsafe(no_mangle)]` is edition 2024 only
- `sim_core` provides `SimStatus`, `Rng`, `Accumulator` — path `../../sim_core`; never use `rand`, `fastrand`, or external RNG
- All `#[repr(C)]` structs must have layout assertion tests using `size_of` and `offset_of`
- Pure-Rust library crates (hal-sim, rtos-sim, device-drivers): `crate-type = ["rlib"]` only, no `cdylib`, no FFI
- Architect reads actual source files before writing implementation prompts; delegates to `swarm-implementor` after planning
- Sim tick throttled to 1 tick per N frames (`TickEveryNFrames = 4` → ~15 ticks/sec at 60fps)

## Domain-Specific

- hal-sim: `i2c.rs write_read()` inlines both write and read steps — `self.write()` then `self.read()` causes `&mut self` double-borrow
- rtos-sim: `Kernel::mutex_lock/unlock` extracts data from `mutexes[idx]` into local `let` bindings BEFORE calling `scheduler` methods
- flight-fsm: `apply_guidance()` is private on `MissionController`, called as Step 0 in `tick()`; FSM is pure state, physics in MissionController
- flight-fsm: Loiter orbit fails silently when vehicle at home (dx=dy=0) — nudge 50 units east when `radius < 1.0`
- flight-fsm: SafeMode must set `velocity[2] = -2.0`; FSM `try_auto_transition` checks `velocity[2] < 0`
- orbital-sim: all computation uses f64 (`DVec3`) internally — f32 conversion only at FFI boundary
- orbital-sim: LEO orbit needs `dt ≤ 1.0s` for stable RK4 integration
- gnc-sim: 6-state EKF uses Joseph form covariance update with hand-rolled 6×6 matrix ops — no external linalg crates
- cpp-interop: manual RAII (raw pointer + destructor) — intentional for defense interview demonstration

## IRONWEIGHT

- BattleTech waist rotation: sim facing `atan2(dy, dx)` from +X; Godot rotation.y forward = -Z; `FACING_OFFSET = PI/2`; `godot_rot = FACING_OFFSET - sim_angle`
- GLB node names in Godot are the Blender **object** name, not the mesh data-block name
- Windows locks `godot_ext.dll` while Godot editor is open — always kill Godot before rebuilding
- `get_mech_armor_fraction` takes 3 args: `(squad_id, mech_index, section_index)` — section_index `1` = CenterTorso
- `generate_all_chassis.py` writes `*-gen.glb` suffix — never overwrites hand-edited models
- MechVisual root stays at identity; individual GLB child nodes rotate independently
- Island-per-component pattern — each visual part is a separate mesh island in shared Blender object
- Option C material strategy: clone `mat_primary` per-instance, 15% faction tint, lerp toward orange/red on damage
- `heat_distortion.gdshader` — `render_mode transparent` invalid for spatial; use `render_mode blend_add`
- Fullscreen `ColorRect` with no material renders solid white — always assign `ShaderMaterial`
- Center `CombatCamera` pivot on midpoint of spawned mechs in `_spawn_squad_visuals()`
- Godot headless run: "Cannot instantiate C# script" after deleting `.godot/mono/` → run `dotnet build` directly

## Linting

### Rust (cargo clippy)
- Config: `rust+godot/clippy.toml` — MSRV 1.75, correctness=deny, style/suspicious=warn
- Format: `rust+godot/rustfmt.toml` — 4-space, 120 max width
- Run: `cargo clippy --all-targets` in each crate directory
- No workspace root — 54 independent crates, each with its own Cargo.toml

### GDScript (gdlint via gdtoolkit)
- Config: `rust+godot/ironweight/godot/.gdlintrc`
- Install: `pip install gdtoolkit` (gdlint is bundled in gdtoolkit v4+)
- Run: `gdlint ironweight/godot/scripts/ ironweight/godot/scenes/`
- Godot 4.x syntax — `@onready`, type hints, `extends`, `class_name`
- Key rules: 4-space indent, PascalCase classes, SCREAMING_SNAKE_CASE constants, snake_case functions/vars

## Key File Locations

- `sim_core/src/rng/lcg.rs` — canonical `Rng` (LCG)
- `domain1/swarm-sim/src/ffi.rs` — 26 extern "C" FFI functions; ABI version 11
- `flight-fsm/src/mission.rs` — `MissionController`, `tick()` 8-step loop
- `orbital-sim/src/ffi.rs` — 12 extern "C" functions, OrbitalHandle
- `gnc-sim/` — pid.rs, filters.rs, ekf.rs, attitude.rs, guidance.rs, autopilot.rs — 90 tests
- `ironweight/blender/output/wie-k-manual.blend` — ACTIVE hand-edited model; DO NOT overwrite
- `ironweight/godot/assets/models/wie-k.glb` — exported GLB (CT, Hip, Turret, Legs)
- `ironweight/godot/scenes/combat/MechVisual.gd` — waist rotation + materials
- `ironweight/godot_ext/src/nodes/combat_manager.rs` — Rust FFI combat functions
- `ironweight/target/debug/godot_ext.dll` — GDExtension DLL
