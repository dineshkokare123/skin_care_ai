import os
from PIL import Image

# Define the order of images
image_order = [
    "splash_screen.png",
    "loading_screen.png",
    "login_screen.png",
    "signup_screen.png",
    "home_screen.png",
    "blog_post.png",
    "sales_analytics.png",
    "profile_premium.png",
    "activity_history.png",
    "order_success.png"
]

images = []
base_path = "screenshots"

print("Starting GIF creation...")

for filename in image_order:
    path = os.path.join(base_path, filename)
    if os.path.exists(path):
        print(f"Processing {filename}...")
        try:
            img = Image.open(path)
            # Resize to Reduce file size (optional, but good for README)
            # Assuming portrait screenshots, let's limit width to 300px to keep GIF size manageable
            base_width = 300
            w_percent = (base_width / float(img.size[0]))
            h_size = int((float(img.size[1]) * float(w_percent)))
            img = img.resize((base_width, h_size), Image.Resampling.LANCZOS)
            images.append(img)
        except Exception as e:
             print(f"Error processing {filename}: {e}")
    else:
        print(f"Warning: {filename} not found.")

if images:
    # Save as GIF
    # duration is in milliseconds. 1500ms = 1.5s per slide
    output_path = "screenshots/app_walkthrough.gif"
    images[0].save(
        output_path,
        save_all=True,
        append_images=images[1:],
        duration=1500,
        loop=0,
        optimize=True
    )
    print(f"GIF saved to {output_path}")
else:
    print("No images found to create GIF.")
