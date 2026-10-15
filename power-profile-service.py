#!/usr/bin/env python3

import tkinter as tk
import subprocess
import psutil
import pyudev
import os

class Splash:
    process = None

    root = tk.Tk()
    root.withdraw()




    def __kill_myself(self):
        try:
            parent = psutil.Process(self.process.pid)
            parent.kill()
        except Exception as e:
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
        file = os.path.abspath(f"/usr/local/share/power-profile-splash-service/assets/{active_profile}.png")
        self.process = subprocess.Popen(
            [
                "yad",
                "--no-buttons",
                "--on-top",
                "--undecorated",
                "--skip-taskbar",
                "--no-focus",
                f"--posx={screen_width}",
                f"--posy={screen_height}",
                "--splash",
                "--text-align=center",
                f"--image={file}",
                "--timeout=1",
                "--borders=0",
            ],
            env={**os.environ, "GDK_BACKEND": "x11"},
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )

def main():
    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    splash = Splash()
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

def just_lib

if __name__ == "__main__":
    main()
