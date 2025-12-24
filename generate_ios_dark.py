import json
import os
from PIL import Image

def generate_ios_dark_icons():
    base_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    json_path = os.path.join(base_dir, 'Contents.json')
    dark_source_path = 'assets/logo_dark.png'
    
    if not os.path.exists(json_path):
        print("Contents.json not found")
        return
        
    with open(json_path, 'r') as f:
        data = json.load(f)
        
    images = data.get('images', [])
    new_images = []
    
    # Load source dark image
    dark_img = Image.open(dark_source_path)
    
    # Track processed filenames to avoid duplicates if re-run (simple check)
    existing_filenames = {img.get('filename') for img in images}
    
    for img in images:
        # Keep original
        new_images.append(img)
        
        # If this is already a specialized appearance, skip (or handle?)
        if 'appearances' in img:
            continue
            
        # Create Dark variant
        original_filename = img['filename']
        # Assumption: filenames are like Icon-App-20x20@2x.png
        # We'll prefix with Dark-
        dark_filename = f"Dark-{original_filename}"
        
        # Calculate target size
        size_str = img['size'] # "20x20"
        scale_str = img['scale'] # "2x"
        
        width = float(size_str.split('x')[0])
        scale = float(scale_str.replace('x', ''))
        pixel_size = int(width * scale)
        
        # Resize dark image
        resized_dark = dark_img.resize((pixel_size, pixel_size), Image.Resampling.LANCZOS)
        resized_dark.save(os.path.join(base_dir, dark_filename))
        print(f"Generated {dark_filename} ({pixel_size}x{pixel_size})")
        
        # Create JSON entry
        dark_entry = img.copy()
        dark_entry['filename'] = dark_filename
        dark_entry['appearances'] = [
            {
                "appearance": "luminosity",
                "value": "dark"
            }
        ]
        new_images.append(dark_entry)
        
    data['images'] = new_images
    
    with open(json_path, 'w') as f:
        json.dump(data, f, indent=2)
    print("Updated Contents.json with Dark appearance icons")

if __name__ == "__main__":
    generate_ios_dark_icons()
