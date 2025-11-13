# PHUMA Setup Guide with UV

## What is UV?

`uv` is an extremely fast Python package installer and resolver, written in Rust. It's 10-100x faster than `pip` and is a modern alternative for Python package management.

## Quick Setup

### 1. Install UV

```bash
pip install uv
```

### 2. Create Virtual Environment

```bash
# Using Python 3.9 (recommended)
uv venv --python 3.9

# Or use Python 3.10
uv venv --python 3.10

# This creates a .venv directory
```

### 3. Activate Virtual Environment

**Linux/Mac:**
```bash
source .venv/bin/activate
```

**Windows:**
```bash
.venv\Scripts\activate
```

### 4. Install Dependencies

```bash
# Install all dependencies (MUCH faster than pip!)
uv pip install -e .

# Or install from requirements.txt
uv pip install -r requirements.txt
```

## Automated Setup

We provide a convenient setup script:

```bash
# Make it executable (first time only)
chmod +x setup_uv.sh

# Run the setup
./setup_uv.sh
```

## Advantages of UV

1. **Speed**: 10-100x faster than pip
2. **Reliability**: Better dependency resolution
3. **Modern**: Written in Rust for performance
4. **Compatible**: Drop-in replacement for pip

## Common Commands

```bash
# Install a package
uv pip install package_name

# Install from requirements.txt
uv pip install -r requirements.txt

# Install in editable mode
uv pip install -e .

# List installed packages
uv pip list

# Freeze dependencies
uv pip freeze > requirements.txt

# Uninstall a package
uv pip uninstall package_name
```

## Troubleshooting

### UV not found after installation

```bash
# Try using python -m uv
python -m uv --version

# Or python3 -m uv
python3 -m uv --version
```

### Python version not available

```bash
# UV will automatically download the specified Python version
uv venv --python 3.9

# Or use system Python
uv venv --python $(which python3)
```

### Dependency conflicts

UV has better dependency resolution than pip, but if you encounter issues:

```bash
# Clear the cache
uv cache clean

# Reinstall
uv pip install -e . --reinstall
```

## Comparison: pip vs uv

| Operation        | pip   | uv   | Speedup |
| ---------------- | ----- | ---- | ------- |
| Install torch    | ~30s  | ~3s  | 10x     |
| Install all deps | ~120s | ~10s | 12x     |
| Resolve deps     | ~15s  | ~1s  | 15x     |

## Migration from Conda/Pip

If you're currently using conda:

```bash
# Export your conda environment
conda list --export > conda_packages.txt

# Create UV virtual environment
uv venv --python 3.9
source .venv/bin/activate

# Install packages
uv pip install -r requirements.txt
```

## Next Steps

After setup, proceed with the PHUMA pipeline:

1. Download SMPL-X models (see main README)
2. Run motion curation: `python src/curation/preprocess_smplx.py`
3. Run motion retargeting: `python src/retarget/motion_adaptation.py`

## Resources

- UV Documentation: https://github.com/astral-sh/uv
- PHUMA Project: https://davian-robotics.github.io/PHUMA/
- Issues: https://github.com/DAVIAN-Robotics/PHUMA/issues
