# Common Learned Patterns

> Universal patterns loaded in all sessions. Project-specific patterns are in separate files.
> Split from learned-patterns.md on 2026-04-10.

## Environment

- `cargo` is NOT on the system PATH → must use full path `C:\Users\ramos\.cargo\bin\cargo.exe`
- CMake generator must match installed VS version — this machine has VS 2026 (version 18); use `-G "Visual Studio 18 2026"`
- Godot editor: `C:\Users\ramos\tools\godot\Godot_v4.6.1-stable_mono_win64.exe`

## User Preferences

- Follows `AI_DEVELOPMENT_GUIDELINES.md` as canonical reference when present
- Prefers review-first workflow: identify all issues before touching any files; work through fixes one section at a time with explicit confirmation
- Wants high-value web content distilled into structured, actionable markdown

## Common Errors

- C# `CS0227: Unsafe code may only appear if compiling with /unsafe` → add `<AllowUnsafeBlocks>true</AllowUnsafeBlocks>` to `<PropertyGroup>` in `.csproj`
- Rust `&mut self` cross-field borrow: holding `self.field_a[idx]` reference while calling `self.field_b.method()` fails — extract needed values into local `let` bindings first
