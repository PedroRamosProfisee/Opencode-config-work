# Hunyuan3D-2 Learned Patterns

> Loaded only in Hunyuan3D-2 workspace sessions.

## Architecture

- Research codebase: Python 3.10+, PyTorch, trimesh, open3d, numpy
- Entry point: `hunyuan3d/` package — check `__init__.py` for exposed APIs
- Mesh I/O: trimesh for reading, open3d for processing, custom serialization for Hunyuan3D format
- Models: `.pt` / `.pth` files tracked via git-lfs — do NOT commit large model files

## Key Conventions

- All 3D computations use **meters** as the canonical unit (not cm or mm)
- Coordinate system: right-handed, Y-up (matching Open3D default)
- Mesh topology changes: always recalculate normals with `open3d.geometry.TriangleMesh.compute_normals()`
- Batch processing: `torch.utils.data.DataLoader` with `num_workers=0` on Windows (fork issue)
- Output directory: `outputs/` committed to gitignore, `runs/` for versioned experiments

## Model Loading

- Use `torch.load(path, map_location='cuda' if torch.cuda.is_available() else 'cpu')`
- FP16 inference: `model.half()` only after loading, before first `forward()`
- Checkpoint saving: always save optimizer state + model state + epoch number

## Ruff Linting

- Config is at `Hunyuan3D-2/ruff.toml` — run `ruff check .` before committing
- Research notebooks (`*.ipynb`): lint is relaxed — review manually before commit
- Type hints (`ANN` rules): partially enforced — don't block on missing type annotations in research code
