import os
from PIL import Image, ImageDraw, ImageFilter

def create_app_icon():
    size = 512
    # Create master image with transparent background
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Rounded rectangle background
    radius = 110
    # Deep luxury background gradient: #1E293B to #0F172A
    for y in range(size):
        ratio = y / size
        # Interpolate between (30, 41, 59) and (15, 23, 42)
        r = int(30 * (1 - ratio) + 15 * ratio)
        g = int(41 * (1 - ratio) + 23 * ratio)
        b = int(59 * (1 - ratio) + 42 * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    # Mask to rounded rectangle
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(16, 16), (size - 16, size - 16)], radius=radius, fill=255)
    
    # Apply mask to background
    base = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    base.paste(img, (0, 0), mask)
    
    base_draw = ImageDraw.Draw(base)
    
    # Draw gold border (#B48D54)
    gold = (180, 141, 84, 255)
    gold_light = (212, 175, 55, 255)
    base_draw.rounded_rectangle([(16, 16), (size - 16, size - 16)], radius=radius, outline=gold, width=6)
    base_draw.rounded_rectangle([(22, 22), (size - 22, size - 22)], radius=radius - 6, outline=(180, 141, 84, 70), width=2)

    # Load source logo
    logo = Image.open("lib/assets/icon.png").convert("RGBA")
    
    # Scale logo nicely to fit within icon width (e.g. 420px wide)
    target_width = 400
    target_height = int(logo.height * (target_width / logo.width))
    logo_resized = logo.resize((target_width, target_height), Image.Resampling.LANCZOS)
    
    # Calculate centered position
    x = (size - target_width) // 2
    y = (size - target_height) // 2 - 10
    
    # Subtle drop shadow for logo
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    shadow.paste(logo_resized, (x, y + 4), logo_resized)
    shadow = shadow.filter(ImageFilter.GaussianBlur(8))
    
    # Combine shadow and logo
    base.alpha_composite(shadow)
    base.paste(logo_resized, (x, y), logo_resized)

    # Add subtitle badge "VISITOR PASS" in gold at bottom
    # Save master icons
    os.makedirs("assets", exist_ok=True)
    os.makedirs("lib/assets", exist_ok=True)
    
    base.save("assets/app_icon.png")
    base.save("lib/assets/app_icon.png")
    print("Created master app_icon.png (512x512)")
    
    # Generate Android launcher icons
    android_res = "android/app/src/main/res"
    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    
    for folder, dim in densities.items():
        out_dir = os.path.join(android_res, folder)
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, "ic_launcher.png")
        resized = base.resize((dim, dim), Image.Resampling.LANCZOS)
        resized.save(out_path)
        print(f"Generated {out_path} ({dim}x{dim})")

if __name__ == "__main__":
    create_app_icon()
