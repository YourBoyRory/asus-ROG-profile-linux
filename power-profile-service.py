#!/usr/bin/env python3

import tkinter as tk
from PIL import Image, ImageTk
import sys
import psutil
import threading
import queue

import pyudev
import os

class Splash:
    files = {}
    close_timer = None
    label = None

    def __init__(self, assets):
        self.commands = queue.Queue()
        self.assets = assets
        self.thread = threading.Thread(
            target=self._run,
            daemon=True
        )
        self.thread.start()

    def _load_images(self):
        quiet = Image.open(f"{self.assets}/quiet.png")
        balanced = Image.open(f"{self.assets}/balanced.png")
        performance = Image.open(f"{self.assets}/performance.png")
        self.files['quiet'] = {
            'width': quiet.width,
            'height': quiet.height,
            'decale': ImageTk.PhotoImage(quiet)
        }
        self.files['balanced'] = {
            'width': balanced.width,
            'height': balanced.height,
            'decale': ImageTk.PhotoImage(balanced)
        }
        self.files['performance'] = {
            'width': performance.width,
            'height': performance.height,
            'decale': ImageTk.PhotoImage(performance)
        }

    def _process_commands(self):
        try:
            while True:
                command, active_profile = self.commands.get_nowait()
                if command == "show":
                    self._show_image(active_profile)
        except queue.Empty:
            pass
        self.root.after(50, self._process_commands)

    def _show_image(self, active_profile):
        image_data = self.files[active_profile]['decale']
        image_width = self.files[active_profile]['width']
        image_height = self.files[active_profile]['height']

        self.label.configure(image=image_data)

        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()

        x = (screen_width - image_width) // 2
        y = (screen_height) // 2

        self.root.geometry(
            f"{image_width}x{image_height}+{x}+{y}"
        )

        self.root.deiconify()
        self.root.update_idletasks()
        self.root.lift()

        # Cancel the previous timer, if one exists.
        if self.close_timer is not None:
            self.root.after_cancel(self.close_timer)

        # Start a fresh one-second timer.
        self.close_timer = self.root.after(
            1000,
            self._hide
        )

    def _hide(self):
        self.root.withdraw()
        self.close_timer = None

    def _run(self):

        self.root = tk.Tk()
        self._load_images()

        self.root.withdraw()
        self.root.overrideredirect(True)
        self.root.attributes("-topmost", True)
        self.root.focusmodel("passive")

        self.label = tk.Label(
            self.root,
            bg="#242424",
            borderwidth=0,
            highlightthickness=0,
            padx=0,
            pady=0,
        )
        self.label.pack()

        self.root.after(50, self._process_commands)
        self.root.mainloop()

    def show(self, active_profile):
        self.commands.put(("show", active_profile))

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

if __name__ == "__main__":
    main()
