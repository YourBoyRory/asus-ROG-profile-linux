
import tkinter as tk
from PIL import Image, ImageTk
import os
import threading
import queue


class Splash:
    def __init__(self, assets):
        self.assets = assets
        self.root = None
        self.label = None
        self.photo = None
        self.close_timer = None

        self.commands = queue.Queue()
        self.thread = threading.Thread(
            target=self._run,
            daemon=True
        )
        self.thread.start()

    def show(self, active_profile):
        file = os.path.abspath(
            os.path.join(self.assets, f"{active_profile}.png")
        )

        # Queue the request and return immediately.
        self.commands.put(("show", file))

    def _run(self):
        self.root = tk.Tk()
        self.root.withdraw()
        self.root.overrideredirect(True)
        self.root.attributes("-topmost", True)
        self.root.focusmodel("passive")

        self.label = tk.Label(
            self.root,
            borderwidth=0,
            highlightthickness=0,
            padx=0,
            pady=0,
        )
        self.label.pack()

        # Process requests from show().
        self.root.after(50, self._process_commands)
        self.root.mainloop()

    def _process_commands(self):
        try:
            while True:
                command, file = self.commands.get_nowait()

                if command == "show":
                    self._show_image(file)

        except queue.Empty:
            pass

        self.root.after(50, self._process_commands)

    def _show_image(self, file):
        image = Image.open(file)
        photo = ImageTk.PhotoImage(image)

        self.photo = photo  # Keep a reference to prevent garbage collection.
        self.label.configure(image=photo)

        width, height = image.size
        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()

        x = (screen_width - width) // 2
        y = (screen_height - height) // 2

        self.root.geometry(
            f"{width}x{height}+{x}+{y}"
        )

        self.root.deiconify()
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
