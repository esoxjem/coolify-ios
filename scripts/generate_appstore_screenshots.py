#!/usr/bin/env python3
"""
Generate App Store screenshots with purple gradient backgrounds and text captions.

Creates 6.9" (1320 x 2868 px) screenshots for App Store submission.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
from pathlib import Path
import math

# Canvas dimensions for 6.9" display
CANVAS_WIDTH = 1320
CANVAS_HEIGHT = 2868

# Gradient colors (Coolify purple)
GRADIENT_TOP = (107, 22, 237)      # #6B16ED
GRADIENT_BOTTOM = (90, 18, 199)    # #5A12C7

# Layout specs
TOP_PADDING = 180
CAPTION_FONT_SIZE = 72
CAPTION_TO_SCREENSHOT_GAP = 60
SCREENSHOT_WIDTH = 1100
CORNER_RADIUS = 44
SHADOW_OFFSET = 15
SHADOW_BLUR = 30

# Screenshot configuration
SCREENSHOTS = [
    ("dashboard.png", "Your Cloud at a Glance"),
    ("deployments.png", "Track Every Deployment"),
    ("deployment-detail.png", "Full Deployment Details"),
    ("settings.png", "Multiple Instances"),
]


def create_gradient(width: int, height: int) -> Image.Image:
    """Create a vertical purple gradient background."""
    gradient = Image.new("RGB", (width, height))

    for y in range(height):
        ratio = y / height
        r = int(GRADIENT_TOP[0] + (GRADIENT_BOTTOM[0] - GRADIENT_TOP[0]) * ratio)
        g = int(GRADIENT_TOP[1] + (GRADIENT_BOTTOM[1] - GRADIENT_TOP[1]) * ratio)
        b = int(GRADIENT_TOP[2] + (GRADIENT_BOTTOM[2] - GRADIENT_TOP[2]) * ratio)

        for x in range(width):
            gradient.putpixel((x, y), (r, g, b))

    return gradient


def create_gradient_fast(width: int, height: int) -> Image.Image:
    """Create a vertical purple gradient background (optimized version)."""
    import numpy as np

    # Create arrays for RGB values
    y_indices = np.linspace(0, 1, height).reshape(-1, 1)

    r = (GRADIENT_TOP[0] + (GRADIENT_BOTTOM[0] - GRADIENT_TOP[0]) * y_indices).astype(np.uint8)
    g = (GRADIENT_TOP[1] + (GRADIENT_BOTTOM[1] - GRADIENT_TOP[1]) * y_indices).astype(np.uint8)
    b = (GRADIENT_TOP[2] + (GRADIENT_BOTTOM[2] - GRADIENT_TOP[2]) * y_indices).astype(np.uint8)

    # Expand to full width
    r = np.tile(r, (1, width))
    g = np.tile(g, (1, width))
    b = np.tile(b, (1, width))

    # Stack into RGB array
    rgb = np.stack([r, g, b], axis=2)

    return Image.fromarray(rgb, mode="RGB")


def add_rounded_corners(image: Image.Image, radius: int) -> Image.Image:
    """Add rounded corners to an image."""
    # Create a mask with rounded corners
    mask = Image.new("L", image.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle(
        [(0, 0), (image.size[0] - 1, image.size[1] - 1)],
        radius=radius,
        fill=255
    )

    # Apply mask to create RGBA image with transparency
    result = image.convert("RGBA")
    result.putalpha(mask)

    return result


def create_shadow(width: int, height: int, radius: int, blur: int, offset: int) -> Image.Image:
    """Create a shadow image for the screenshot."""
    # Create a larger canvas for the shadow
    shadow_canvas = Image.new("RGBA", (width + blur * 2, height + blur * 2), (0, 0, 0, 0))
    shadow = Image.new("RGBA", (width, height), (0, 0, 0, 80))  # Semi-transparent black
    shadow = add_rounded_corners(shadow, radius)

    shadow_canvas.paste(shadow, (blur, blur), shadow)
    shadow_canvas = shadow_canvas.filter(ImageFilter.GaussianBlur(blur // 2))

    return shadow_canvas


def get_font(size: int, mono: bool = False) -> ImageFont.FreeTypeFont:
    """Get a suitable font for captions."""
    if mono:
        # Monospace fonts - SF Mono or Menlo
        font_paths = [
            "/System/Library/Fonts/SFMono-Bold.otf",
            "/System/Library/Fonts/SFMono.ttf",
            "/Library/Fonts/SF-Mono-Bold.otf",
            "/System/Library/Fonts/Menlo.ttc",
            "/System/Library/Fonts/Monaco.ttf",
        ]
    else:
        # Sans-serif fonts
        font_paths = [
            "/System/Library/Fonts/SFNSDisplay.ttf",
            "/System/Library/Fonts/SFNS.ttf",
            "/Library/Fonts/SF-Pro-Display-Bold.otf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/System/Library/Fonts/Helvetica.ttc",
        ]

    for font_path in font_paths:
        try:
            return ImageFont.truetype(font_path, size)
        except (OSError, IOError):
            continue

    # Fallback to default
    return ImageFont.load_default()


def generate_screenshot(
    source_path: Path,
    caption: str,
    output_path: Path
) -> None:
    """Generate a single App Store screenshot."""
    print(f"Processing: {source_path.name} -> {output_path.name}")

    # Create gradient background
    try:
        import numpy as np
        canvas = create_gradient_fast(CANVAS_WIDTH, CANVAS_HEIGHT)
    except ImportError:
        canvas = create_gradient(CANVAS_WIDTH, CANVAS_HEIGHT)

    canvas = canvas.convert("RGBA")

    # Load and scale source screenshot
    source = Image.open(source_path)

    # Calculate scaled dimensions maintaining aspect ratio
    aspect_ratio = source.height / source.width
    scaled_width = SCREENSHOT_WIDTH
    scaled_height = int(scaled_width * aspect_ratio)

    source_scaled = source.resize((scaled_width, scaled_height), Image.Resampling.LANCZOS)
    source_rounded = add_rounded_corners(source_scaled, CORNER_RADIUS)

    # Create shadow
    shadow = create_shadow(scaled_width, scaled_height, CORNER_RADIUS, SHADOW_BLUR, SHADOW_OFFSET)

    # Calculate positions
    caption_y = TOP_PADDING
    screenshot_x = (CANVAS_WIDTH - scaled_width) // 2
    screenshot_y = caption_y + CAPTION_FONT_SIZE + CAPTION_TO_SCREENSHOT_GAP

    # Paste shadow (offset down and right for depth effect)
    shadow_x = screenshot_x - SHADOW_BLUR + SHADOW_OFFSET
    shadow_y = screenshot_y - SHADOW_BLUR + SHADOW_OFFSET
    canvas.paste(shadow, (shadow_x, shadow_y), shadow)

    # Paste screenshot
    canvas.paste(source_rounded, (screenshot_x, screenshot_y), source_rounded)

    # Add caption text
    draw = ImageDraw.Draw(canvas)
    font = get_font(CAPTION_FONT_SIZE, mono=True)

    # Calculate text position (centered)
    text_bbox = draw.textbbox((0, 0), caption, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_x = (CANVAS_WIDTH - text_width) // 2

    draw.text((text_x, caption_y), caption, fill="white", font=font)

    # Save output
    canvas = canvas.convert("RGB")  # Convert back to RGB for JPEG/PNG without alpha
    canvas.save(output_path, "PNG", quality=95)
    print(f"  Saved: {output_path} ({CANVAS_WIDTH}x{CANVAS_HEIGHT})")


def main():
    # Determine paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent

    source_dir = project_root / "docs" / "screenshots"
    output_dir = project_root / "docs" / "appstore-screenshots"

    # Create output directory if it doesn't exist
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Source directory: {source_dir}")
    print(f"Output directory: {output_dir}")
    print(f"Canvas size: {CANVAS_WIDTH}x{CANVAS_HEIGHT}px")
    print()

    # Generate each screenshot
    for source_file, caption in SCREENSHOTS:
        source_path = source_dir / source_file

        if not source_path.exists():
            print(f"Warning: Source file not found: {source_path}")
            continue

        output_path = output_dir / f"appstore_{source_file}"
        generate_screenshot(source_path, caption, output_path)

    print()
    print("Done! Generated App Store screenshots.")


if __name__ == "__main__":
    main()
