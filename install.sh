#!/bin/bash

# Video Thumbnailer Installation Script
# Run this script to set up the Video Thumbnailer Quick Action

set -e

echo "🎬 Video Thumbnailer Installation"
echo "================================="

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is required but not installed"
    echo "Please install Homebrew first: https://brew.sh"
    exit 1
fi

# Install ffmpeg if not present
if ! command -v ffmpeg &> /dev/null; then
    echo "📦 Installing ffmpeg..."
    brew install ffmpeg
else
    echo "✅ ffmpeg is already installed"
fi

# Create directory structure
INSTALL_DIR="$HOME/VideoThumbnailer"
echo "📁 Creating directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Copy Python script
echo "📋 Copying video_thumbnailer.py..."
cp video_thumbnailer.py "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/video_thumbnailer.py"

# Check if Quick Action workflow exists
if [[ -f "Video Thumbnailer.workflow" ]]; then
    echo "🔧 Installing Quick Action..."
    echo "Please click 'Install' when Automator opens..."
    open "Video Thumbnailer.workflow"
else
    echo "⚠️  Quick Action workflow not found"
    echo "Please install the Automator workflow manually"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "To use:"
echo "1. Right-click video files in Finder"
echo "2. Go to Services → 'Video Thumbnailer'"
echo "3. Thumbnails will appear in a 'thumbnails' subfolder"
echo ""
echo "If the Quick Action doesn't appear, check:"
echo "System Preferences → Extensions → Finder Extensions"