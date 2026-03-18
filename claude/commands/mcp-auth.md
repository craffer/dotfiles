---
argument-hint: ""
description: "Run the mcp-adaptor authentication command to set up keyring access"
---

Run the mcp-adaptor authentication command to set up keyring access. This will open a browser for authentication:

```bash
# Find the mcp-adaptor binary
MCP_ADAPTOR_BIN=$(find "$HOME/.mcp-adaptor/bin" -name "mcp-adaptor-*" -type f 2>/dev/null | head -1)

if [ -z "$MCP_ADAPTOR_BIN" ]; then
    echo "❌ Error: mcp-adaptor binary not found in $HOME/.mcp-adaptor/bin"
    echo "Please ensure mcp-adaptor is properly installed."
    exit 1
fi

# Run the auth command
echo "🔐 Starting mcp-adaptor authentication..."
echo "This will open a browser for authentication."
$MCP_ADAPTOR_BIN auth

if [ $? -eq 0 ]; then
    echo "✅ Authentication completed successfully!"
else
    echo "❌ Authentication failed. Please check the error messages above."
    exit 1
fi
```

The authentication process will:
1. Open your default browser to the authentication portal
2. Prompt you to authenticate with your credentials
3. Store the authentication token securely in your system keyring
4. Configure the mcp-adaptor to use the authenticated session

After authentication, you may need to restart Claude Code for the changes to take effect.
