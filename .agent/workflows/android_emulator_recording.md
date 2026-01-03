---
description: How to record a video of the Android Emulator
---

# How to Record an App Walkthrough on Android Emulator

## Method 1: Using the Emulator UI (Easiest)

1. With the Android Emulator running, look for the toolbar menu (usually on the right side of the simulated phone).
2. Click the **three dots (...)** at the bottom of the toolbar to open "Extended Controls".
3. Select **screen record** from the left-hand menu.
4. Click **Start recording**.
5. Perform your app walkthrough.
6. Click **Stop recording**.
7. A dialog will appear. Click **Save** to save the `.mp4` or `.webm` file to your computer.

## Method 2: Using ADB Command Line (For higher control)

1. Open your terminal.
2. Run the following command to start recording:

    ```bash
    adb shell screenrecord /sdcard/demo_walkthrough.mp4
    ```

    (Note: The default time limit is 3 minutes. press `Ctrl + C` to stop early).
3. Perform your interaction in the emulator.
4. Press `Ctrl + C` in the terminal to stop recording.
5. Pull the video file from the emulator to your current directory:

    ```bash
    adb pull /sdcard/demo_walkthrough.mp4 .
    ```

## Method 3: macOS Screen Record

1. Press `Cmd + Shift + 5`.
2. Select "Record Selected Portion".
3. Drag the selection box over the Emulator window.
4. Click **Record**.
5. Perform your walkthrough.
6. Click the Stop icon in the macOS menu bar.
