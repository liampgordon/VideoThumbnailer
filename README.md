# Video Thumbnailer - Mac Quick Action

Generate high-quality video thumbnails directly from Finder using ffmpeg.

## Features

- Right-click video files in Finder → Services → "Video Thumbnailer"
- Automatically creates `thumbnails/` subfolder in the same directory
- Uses ffmpeg's intelligent thumbnail filter to pick the best frame
- Scales thumbnails to 720px wide (maintains aspect ratio)
- Supports all video formats that ffmpeg can read

## Installation

### Prerequisites

1. **Install ffmpeg** (required):
   ```bash
   brew install ffmpeg
   ```

2. **Install Python 3** (usually pre-installed on Mac):
   ```bash
   python3 --version
   ```

### Setup Steps

1. **Copy the script**:
   - Place `video_thumbnailer.py` in `/Users/[username]/VideoThumbnailer/`
   - Make it executable: `chmod +x video_thumbnailer.py`

2. **Install the Quick Action**:
   - Double-click `Video Thumbnailer.workflow` to install
   - Or manually import in Automator

3. **Test the installation**:
   - Right-click any video file in Finder
   - Go to Services → "Video Thumbnailer"
   - Check for `thumbnails/` folder with .jpg files

## Usage

1. Select one or more video files in Finder
2. Right-click → Services → "Video Thumbnailer"
3. Thumbnails will be created in a `thumbnails/` subfolder
4. Each thumbnail is named `[original-filename].jpg`

## Troubleshooting

- **"ffmpeg not found"**: Run `brew install ffmpeg`
- **Quick Action not appearing**: Check System Preferences → Extensions → Finder
- **Permission errors**: Ensure the script has execute permissions

## For IT Deployment

### Automated Installation Script

```bash
#!/bin/bash
# Install ffmpeg if not present
if ! command -v ffmpeg &> /dev/null; then
    echo "Installing ffmpeg..."
    brew install ffmpeg
fi

# Create directory and copy script
mkdir -p ~/VideoThumbnailer
cp video_thumbnailer.py ~/VideoThumbnailer/
chmod +x ~/VideoThumbnailer/video_thumbnailer.py

# Install Quick Action
open "Generate Video Thumbnails.workflow"
```

### Manual Deployment

1. Ensure ffmpeg is installed on all machines
2. Copy `video_thumbnailer.py` to a consistent location
3. Update the path in the Automator workflow if needed
4. Distribute the `.workflow` file to users

## Technical Details

- **Thumbnail Algorithm**: Uses ffmpeg's `thumbnail` filter (picks most representative frame)
- **Scaling**: Scales to 720px wide, maintains aspect ratio
- **Output Format**: JPEG with standard quality
- **Dependencies**: Python 3 (built-in), ffmpeg (Homebrew)