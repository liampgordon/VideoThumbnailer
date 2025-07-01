#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path


def generate_thumbnail(video_path, output_dir=None):
    """
    Generate a thumbnail from a video file using ffmpeg.
    
    Args:
        video_path: Path to the input video file
        output_dir: Directory to save thumbnail (defaults to same as video)
    
    Returns:
        Path to generated thumbnail or None if failed
    """
    video_path = Path(video_path)
    
    if not video_path.exists():
        print(f"Error: Video file not found: {video_path}")
        return None
    
    # Determine output path
    if output_dir:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        thumbnail_path = output_dir / f"{video_path.stem}.jpg"
    else:
        # Create thumbnails subfolder in the same directory as the video
        thumbnails_dir = video_path.parent / "thumbnails"
        thumbnails_dir.mkdir(exist_ok=True)
        thumbnail_path = thumbnails_dir / f"{video_path.stem}.jpg"
    
    # Build ffmpeg command
    # -vf "thumbnail,scale=720:-1" applies thumbnail filter then scales to 720px wide
    # -frames:v 1 outputs only one frame
    # -y overwrites existing files
    cmd = [
        'ffmpeg',
        '-i', str(video_path),
        '-vf', 'thumbnail,scale=720:-1',
        '-frames:v', '1',
        '-y',
        str(thumbnail_path)
    ]
    
    try:
        # Run ffmpeg with suppressed output
        result = subprocess.run(
            cmd, 
            capture_output=True, 
            text=True, 
            check=True
        )
        print(f"✓ Generated thumbnail: {thumbnail_path}")
        return thumbnail_path
        
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to generate thumbnail for {video_path}")
        print(f"  Error: {e.stderr}")
        return None
    except FileNotFoundError:
        print("Error: ffmpeg not found. Please install ffmpeg first.")
        return None


def main():
    parser = argparse.ArgumentParser(
        description="Generate thumbnails from video files using ffmpeg",
        epilog="Example: python video_thumbnailer.py video1.mp4 video2.mov --output-dir thumbnails/"
    )
    
    parser.add_argument(
        'videos',
        nargs='+',
        help='Video files to process'
    )
    
    parser.add_argument(
        '-o', '--output-dir',
        help='Output directory for thumbnails (default: same as video file)'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose output'
    )
    
    args = parser.parse_args()
    
    # Process each video file
    success_count = 0
    total_count = len(args.videos)
    
    for video_file in args.videos:
        if args.verbose:
            print(f"Processing: {video_file}")
        
        result = generate_thumbnail(video_file, args.output_dir)
        if result:
            success_count += 1
    
    print(f"\nCompleted: {success_count}/{total_count} thumbnails generated")
    
    # Exit with error code if some failed
    if success_count < total_count:
        sys.exit(1)


if __name__ == '__main__':
    main()