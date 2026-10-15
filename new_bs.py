import tkinter as tk
from PIL import Image, ImageTk
import sys

file = "./assets/quiet.png"
screen_width = 1920//2
screen_height = 1080//2

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
