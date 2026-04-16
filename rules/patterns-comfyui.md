# ComfyUI Learned Patterns

> Loaded only in ComfyUI workspace sessions.

## Architecture

- ComfyUI is a node-graph execution engine — custom nodes live in `custom_nodes/`
- Core execution: `ComfyUI/comfy/` (Python, no type hints)
- Frontend: `ComfyUI/web/` (JS/TS, Vite)
- Embedded Python: `ComfyUI/python_embeded/` (vendored, do NOT modify)
- The Python SDK is NOT exposed as a pip package — import paths are relative to the repo root

## Workflow Patterns

- Custom node registration: subclass `BaseNode` or use `@torch.no_grad()` decorated functions
- Torch tensors: always use `.float()` for consistency; half-precision (`half()`) only for GPU memory optimization
- Memory management: `torch.cuda.empty_cache()` after large batches
- Node execution order: ComfyUI handles topological sort — do NOT hardcode execution order in nodes

## Common Pitfalls

- Mutating input tensors in-place breaks graph caching — always `.clone()` before modification
- Model files (>100MB) live outside the repo — paths are hardcoded in `model_paths.yml`
- `torch.load()` with `map_location='cpu'` is required for cross-device loading
- Batch inference: use `torch.stack()` then `torch.chunk()` not individual calls

## Linting

- ruff config is in `ComfyUI/pyproject.toml` — already configured
- Target: Python 3.10, `torch >= 2.0`, `numpy`
- Custom node authors: always add `PYTHONPATH=ComfyUI python -m mypy custom_nodes/my_node/` before PR
