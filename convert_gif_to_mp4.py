from moviepy import *

try:
    print("Loading GIF...")
    clip = VideoFileClip("screenshots/app_walkthrough.gif")
    print("Converting to MP4...")
    clip.write_videofile("screenshots/app_walkthrough.mp4", codec="libx264")
    print("Done!")
except Exception as e:
    print(f"Error: {e}")
