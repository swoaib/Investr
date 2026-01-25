import os
import sys
import subprocess

# Install Pillow if not attached
try:
    from PIL import Image
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image

def process_logo():
    source_path = 'assets/logo.png'
    transparent_output_path = 'assets/logo_transparent.png'
    dark_output_path = 'assets/logo_dark.png'

    print(f"Processing {source_path}...")

    img = Image.open(source_path)
    img = img.convert("RGBA")
    datas = img.getdata()

    newData = []
    # Threshold for what we consider "white"
    threshold = 240

    for item in datas:
        # item is (R, G, B, A)
        if item[0] > threshold and item[1] > threshold and item[2] > threshold:
            newData.append((255, 255, 255, 0)) # Make Transparent
        else:
            newData.append(item)

    img.putdata(newData)
    img.save(transparent_output_path, "PNG")
    print(f"Saved transparent logo to {transparent_output_path}")

    # Create Dark iOS version (Opaque Black background with original logo)
    # The original logo is white-ish, so it should look okay on black.
    # But wait, the original logo has a white background.
    # So we should use the transparent one we just made and paste it on black.

    transparent_img = Image.open(transparent_output_path)
    background = Image.new("RGBA", img.size, (0, 0, 0, 255))
    background.paste(transparent_img, (0, 0), transparent_img)
    background.save(dark_output_path, "PNG")
    print(f"Saved dark logo to {dark_output_path}")

    # Create Staging version (Amber background)
    staging_output_path = 'assets/logo_staging.png'
    amber_background = Image.new("RGBA", img.size, (255, 193, 7, 255)) # Amber color
    amber_background.paste(transparent_img, (0, 0), transparent_img)
    amber_background.save(staging_output_path, "PNG")
    print(f"Saved staging logo to {staging_output_path}")

    # Create Deep Orange version
    deep_orange_output_path = 'assets/logo_deep_orange.png'
    deep_orange_background = Image.new("RGBA", img.size, (255, 87, 34, 255)) # Deep Orange color
    deep_orange_background.paste(transparent_img, (0, 0), transparent_img)
    deep_orange_background.save(deep_orange_output_path, "PNG")
    print(f"Saved deep orange logo to {deep_orange_output_path}")

if __name__ == "__main__":
    process_logo()
