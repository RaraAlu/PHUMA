#!/bin/bash
# PHUMA Setup Script using UV
# Fast and modern Python package management

set -e

echo "🚀 PHUMA Setup Script - Using UV"
echo "=================================="

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "📦 UV not found. Installing UV..."
    pip install uv
    echo "✅ UV installed successfully!"
else
    echo "✅ UV is already installed (version: $(uv --version))"
fi

# Create virtual environment
echo ""
echo "🔧 Creating virtual environment with Python 3.9..."
uv venv --python 3.9 || uv venv --python 3.10

# Activate virtual environment
echo ""
echo "📂 Virtual environment created at: .venv"
echo "To activate it, run:"
echo "  source .venv/bin/activate    # Linux/Mac"
echo "  .venv\\Scripts\\activate      # Windows"
echo ""

# Install dependencies
echo "📥 Installing dependencies..."
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
    echo "✅ Virtual environment activated"
fi

echo "Installing packages with UV (this is much faster than pip)..."
uv pip install -e .

echo ""
echo "✅ Installation completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Activate the environment: source .venv/bin/activate"
echo "2. Download SMPL-X models from: https://smpl-x.is.tue.mpg.de/"
echo "3. Place SMPL-X files in: asset/human_model/smplx/"
echo "4. Run the example: python src/curation/preprocess_smplx.py --help"
echo ""
echo "🎉 Happy coding with PHUMA!"
