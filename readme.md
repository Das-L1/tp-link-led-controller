# LED Control Setup for OpenWRT

This repository provides a setup script and configuration files to control router LEDs using HTTP requests on OpenWRT. The script automates the setup of a CGI interface and persistent LED configurations.

---

## Features

- Control router LEDs via HTTP (`curl` or web requests).
- Persistent LED configurations in `/etc/config/system`.
- Compatible with OpenWRT's `uhttpd` web server.

---

## Requirements

- OpenWRT router with LED control support.
- SSH access to the router.

---

## Installation

1. Clone the repository or download the setup script.
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. Copy the `setup_led_control.sh` script to your router.
   ```bash
   scp setup_led_control.sh root@<router_ip>:/root/
   ```

3. SSH into your router:
   ```bash
   ssh root@<router_ip>
   ```

4. Make the script executable:
   ```bash
   chmod +x /root/setup_led_control.sh
   ```

5. Run the script:
   ```bash
   /root/setup_led_control.sh
   ```

---

## Usage

### Controlling LEDs
- Turn on an LED:
  ```bash
  curl "http://<router_ip>/cgi-bin/led_control?led=<led_name>&action=on"
  ```

- Turn off an LED:
  ```bash
  curl "http://<router_ip>/cgi-bin/led_control?led=<led_name>&action=off"
  ```

- List available LEDs:
  ```bash
  ls /sys/class/leds/
  ```

### Examples
- Turn on the `tp-link:green:lan1` LED:
  ```bash
  curl "http://192.168.1.1/cgi-bin/led_control?led=tp-link:green:lan1&action=on"
  ```

- Turn off the `tp-link:green:lan1` LED:
  ```bash
  curl "http://192.168.1.1/cgi-bin/led_control?led=tp-link:green:lan1&action=off"
  ```

---

## Notes

- Ensure CGI scripts are enabled in the `uhttpd` configuration.
- Use `ls /sys/class/leds/` to find available LED names on your router.

---

## Troubleshooting

- **403 Forbidden:** Ensure the CGI script has executable permissions:
  ```bash
  chmod +x /www/cgi-bin/led_control
  ```

- **LED not responding:**
  - Check if the LED trigger is set to `none`:
    ```bash
    echo none > /sys/class/leds/<led_name>/trigger
    ```
  - Try turning the LED on manually:
    ```bash
    echo 1 > /sys/class/leds/<led_name>/brightness
    ```

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

