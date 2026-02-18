#!/bin/bash
set -euo pipefail

launch_agent_dir="${HOME}/Library/LaunchAgents"
plist="${launch_agent_dir}/com.conor.keyremap.caps-to-esc.plist"
mapping='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'

mkdir -p "$launch_agent_dir"

cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.conor.keyremap.caps-to-esc</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>$mapping</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

/usr/bin/hidutil property --set "$mapping" || true
/bin/launchctl bootout "gui/$(id -u)" "$plist" >/dev/null 2>&1 || true
/bin/launchctl bootstrap "gui/$(id -u)" "$plist" >/dev/null 2>&1 || true
/bin/launchctl enable "gui/$(id -u)/com.conor.keyremap.caps-to-esc" >/dev/null 2>&1 || true

echo "Caps Lock mapped to Escape (persisted with LaunchAgent)."
