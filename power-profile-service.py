#!/usr/bin/env python3

import tkinter as tk
from PIL import Image, ImageTk
import sys
import psutil

import pyudev
import os

class Splash:
    process = None

    root = tk.Tk()
    root.withdraw()

    def __init__(self, assets):
        self.assets = assets

    def __kill_myself(self):
        try:
            parent = psutil.Process(self.process.pid)
            parent.kill()
        except Exception as e:
            # I cant even do that right
            pass

    def __get_center(self):
        image_width = 250
        screen_height = 250
        screen_width = ( image_width // 2 ) - ( self.root.winfo_screenwidth() // 2 )
        screen_height = ( self.root.winfo_screenheight() // 2 )
        return screen_width, screen_height

    def show(self, active_profile):
        self.__kill_myself()
        screen_width, screen_height = self.__get_center()
        file = os.path.abspath(f"{self.assets}/{active_profile}.png")
        print(file)

        root = tk.Tk()

        # Remove window decorations and bypass normal window management.
        root.overrideredirect(True)

        # Keep the popup above normal windows.
        root.attributes("-topmost", True)

        # Load and display the image.
        image = Image.open(file)
        photo = ImageTk.PhotoImage(image)

        label = tk.Label(
            root,
            image=photo,
            borderwidth=0,
            highlightthickness=0,
            padx=0,
            pady=0,
        )
        label.pack()

        # Position the window at the requested coordinates.
        root.geometry(f"{image.width}x{image.height}+{screen_width}+{screen_height}")

        # Avoid requesting focus.
        root.focusmodel("passive")

        # Close after one second.
        root.after(1000, root.destroy)

        root.mainloop()

def main():
    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    splash = Splash("/usr/local/share/power-profile-splash-service/assets")
    monitor.filter_by(subsystem='platform-profile')
    for device in iter(monitor.poll, None):
        if device.action == 'change':
            profile_path = os.path.join(device.sys_path, 'profile')
            try:
                with open(profile_path, 'r') as f:
                    active_profile = f.read().strip()
                if active_profile == "quiet":
                    splash.show("quiet")
                elif active_profile == "balanced":
                    splash.show("balanced")
                elif active_profile == "performance":
                    splash.show("performance")
            except FileNotFoundError:
                print(f"Could not read profile state at {profile_path}")

def just_splash():
    splash = Splash("./assets")
    splash.show("quiet")

if __name__ == "__main__":
    #main()
    just_splash()
