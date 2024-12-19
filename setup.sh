#!/bin/sh

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Define variables
CGI_PATH="/www/cgi-bin/led_control"
LED_PATH="/sys/class/leds"
SYSTEM_CONFIG="/etc/config/system"
UHTTPD_CONFIG="/etc/config/uhttpd"

# Step 1: Create the CGI Script
cat > $CGI_PATH << 'EOF'
#!/bin/sh
echo "Content-Type: application/json"
echo ""

# Base directory for LEDs
LED_PATH="/sys/class/leds"

# Parse query parameters
LED=$(echo "$QUERY_STRING" | sed -n 's/.*led=\([^&]*\).*/\1/p')
ACTION=$(echo "$QUERY_STRING" | sed -n 's/.*action=\([^&]*\).*/\1/p')

# Check if parameters are provided
if [ -z "$LED" ] || [ -z "$ACTION" ]; then
    echo '{"status":"error","message":"Missing parameters"}'
    exit 1
fi

# Validate the LED path
if [ ! -d "$LED_PATH/$LED" ]; then
    echo '{"status":"error","message":"Invalid LED name"}'
    exit 1
fi

# Perform the action
if [ "$ACTION" = "on" ]; then
    echo none > "$LED_PATH/$LED/trigger"
    echo 1 > "$LED_PATH/$LED/brightness"
    echo '{"status":"success","message":"LED turned on"}'
elif [ "$ACTION" = "off" ]; then
    echo none > "$LED_PATH/$LED/trigger"
    echo 0 > "$LED_PATH/$LED/brightness"
    echo '{"status":"success","message":"LED turned off"}'
else
    echo '{"status":"error","message":"Invalid action"}'
    exit 1
fi
EOF

# Step 2: Set Permissions for CGI Script
chmod +x $CGI_PATH

# Step 3: Verify LEDs Directory
if [ ! -d "$LED_PATH" ]; then
  echo "Error: $LED_PATH does not exist. Ensure this router supports LED control."
  exit 1
fi

# Step 4: Update uhttpd Configuration
if ! grep -q "cgi-bin" $UHTTPD_CONFIG; then
  echo "Adding CGI configuration to $UHTTPD_CONFIG..."
  uci set uhttpd.main.cgi_prefix='/cgi-bin'
  uci commit uhttpd
  /etc/init.d/uhttpd restart
else
  echo "uhttpd is already configured for CGI."
fi

# Step 5: Update /etc/config/system for Persistent LED Settings
echo "Updating /etc/config/system for persistent LED configurations..."
for LED in $(ls $LED_PATH); do
  uci add system led
  uci set system.@led[-1].name="$LED"
  uci set system.@led[-1].sysfs="$LED"
  uci set system.@led[-1].default='0'
  uci set system.@led[-1].trigger='none'
done
uci commit system

# Step 6: Restart System Service
/etc/init.d/system restart

# Step 7: Provide Usage Instructions
cat << "USAGE"
Setup complete! You can now control the router LEDs using HTTP requests.
Examples:

Turn on an LED:
  curl "http://<router_ip>/cgi-bin/led_control?led=<led_name>&action=on"

Turn off an LED:
  curl "http://<router_ip>/cgi-bin/led_control?led=<led_name>&action=off"

List available LEDs:
  ls /sys/class/leds/

Replace <router_ip> with your router's IP address and <led_name> with the specific LED name.

NOTE: Persistent LED configurations have been added to /etc/config/system.
USAGE

exit 0
