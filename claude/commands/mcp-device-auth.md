Run the mcp-adaptor device authentication command. This will start the OAuth2 Device Code Flow.

**IMPORTANT: Set the environment variable to enable Device Code Flow:**

```bash
# Find the mcp-adaptor binary
MCP_ADAPTOR_BIN=$(find "$HOME/.mcp-adaptor/bin" -name "mcp-adaptor-*" -type f 2>/dev/null | head -1)

if [ -z "$MCP_ADAPTOR_BIN" ]; then
    echo "❌ Error: mcp-adaptor binary not found in $HOME/.mcp-adaptor/bin"
    echo "Please ensure mcp-adaptor is properly installed."
    exit 1
fi

# Run the device auth command with device flow enabled
echo "🔐 Starting mcp-adaptor device authentication..."
echo "This will use OAuth2 Device Code Flow."
MCP_ADAPTOR_ENABLE_DEVICE_FLOW=true $MCP_ADAPTOR_BIN auth

if [ $? -eq 0 ]; then
    echo "✅ Device authentication completed successfully!"
else
    echo "❌ Device authentication failed. Please check the error messages above."
    exit 1
fi
```

Run the auth command in the background to capture output. The flow will be:

1. The tool will display a verification URL and a device code
2. Parse the output to find the URL after "🔗 Quick link (pre-filled code):"
3. **Check if browser can be opened automatically:**
   - On macOS: Check if `open` command is available
   - On Linux/Unix: Check if DISPLAY environment variable is set (X11 available)
   - On Windows: Check if `start` command is available
4. **If browser can be opened:** Automatically open the URL using:
   - macOS: `open <url>`
   - Linux: `xdg-open <url>` or `sensible-browser <url>`
   - Windows: `start <url>`
5. **If browser CANNOT be opened (headless/SSH environment):**
   - Display the quick link URL prominently to the user
   - Ask the user to manually open the URL in their browser
   - Inform them the device code is pre-filled in the URL
6. The user will complete the authorization in their browser (the device code is pre-filled)
7. Wait for the tool to poll and confirm authorization completion
8. Once authorized, tokens will be stored securely in the keyring

Important:
- **Always set `MCP_ADAPTOR_ENABLE_DEVICE_FLOW=true`** before running the auth command
- Run the auth command in the background to capture output and extract the URL
- Only open the browser if Device Code Flow is triggered (output contains "Device Code Flow")
- Extract and open the quick link URL (the one with pre-filled code)
- Detect the environment and decide whether to auto-open or ask user to open manually
- Do not proceed until the authentication is complete. The output will show "Authentication successful!" when done.
