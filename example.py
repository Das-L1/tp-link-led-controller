import tkinter as tk
import requests

def control_led(led_name, action):
    try:
        url = f"http://192.168.1.1/cgi-bin/led_control?led={led_name}&action={action}"
        response = requests.get(url)
        if response.status_code == 200:
            status_label.config(text=f"{led_name} is {action.upper()}", fg="green")
        else:
            status_label.config(text=f"Failed to {action} {led_name}", fg="red")
    except Exception as e:
        status_label.config(text=f"Error: {e}", fg="red")

# Create the main window
root = tk.Tk()
root.title("LED Controller")
root.geometry("400x400")
root.configure(background='black')

# Add a label
label = tk.Label(root, text="LED Controller", font=("Terminal", 20), fg="white")
label.pack(pady=15)
label.configure(background='black')

# List of LEDs
leds = [
    "tp-link:green:system",
    "tp-link:green:wan",
    "tp-link:green:lan1",
    "tp-link:green:lan2",
    "tp-link:green:lan3",
    "tp-link:green:lan4",
    "tp-link:green:wlan",
    "tp-link:green:qss",
    "ath9k-phy0"
]


# Add buttons for each LED
for led in leds:
    frame = tk.Frame(root, bg='black')
    frame.pack(pady=5)

    led_label = tk.Label(frame, text=led, font=("Terminal", 12), fg="white", bg="black")
    led_label.pack(side=tk.LEFT, padx=10)

    on_button = tk.Button(frame, text="Turn On", font=("Terminal", 10), bg="green", fg="white", 
                          command=lambda led=led: control_led(led, "on"))
    on_button.pack(side=tk.LEFT, padx=5)

    off_button = tk.Button(frame, text="Turn Off", font=("Terminal", 10), bg="red", fg="white", 
                           command=lambda led=led: control_led(led, "off"))
    off_button.pack(side=tk.LEFT, padx=5)

# Add a status label
status_label = tk.Label(root, text="", font=("Terminal", 15), fg="white", bg="black")
status_label.pack(pady=15)

# Run the application
root.mainloop()
