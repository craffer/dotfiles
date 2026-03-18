---
argument-hint: "profile|list|current"
description: "Switch MCP adaptor to use specified AI Exchange profile. Use 'list' to see available profiles, 'current' to see active profile"
---

I'll help you manage your AI Exchange profiles for the mcp-adaptor server.

**Command:** $ARGUMENTS

Let me handle your profile request:

```bash
# Handle the user command
COMMAND="$ARGUMENTS"
PROFILES_FILE="$HOME/.mcp-adaptor/profiles.json"

# Check if profiles.json exists
if [ ! -f "$PROFILES_FILE" ]; then
    echo "❌ Error: profiles.json not found at $PROFILES_FILE"
    echo "Please ensure your MCP adaptor is properly configured."
    exit 1
fi

# Handle special commands first
if [ "$COMMAND" = "list" ]; then
    echo "📋 AI Exchange Profiles:"
    grep -A 1 '"name":' "$PROFILES_FILE" | grep -E '"name"|"description"' | sed 'N;s/.*"name": *"\([^"]*\)".*\n.*"description": *"\([^"]*\)".*/• \1: \2/'
    echo ""
    echo "Usage: /ai-exchange-profile <name> | current | list"
    exit 0
fi

if [ "$COMMAND" = "current" ]; then
    CURRENT_PROFILE=$(grep -A 5 '"mcp-adaptor"' ~/.claude.json | grep '"GW_PROFILE"' | sed 's/.*"GW_PROFILE": *"\([^"]*\)".*/\1/' 2>/dev/null)
    if [ -n "$CURRENT_PROFILE" ]; then
        echo "🔍 Active Profile: $CURRENT_PROFILE"
        CURRENT_DESC=$(grep -A 3 '"name": *"'"$CURRENT_PROFILE"'"' "$PROFILES_FILE" | grep '"description"' | sed 's/.*"description": *"\([^"]*\)".*/\1/' 2>/dev/null)
        if [ -n "$CURRENT_DESC" ]; then
            echo "📝 Description: $CURRENT_DESC"
        else
            echo "📝 Description: (no description available)"
        fi
        echo ""
        echo "💡 Use '/ai-exchange-profile list' to see all profiles"
    else
        echo "❌ No active profile found"
        echo "💡 Use '/ai-exchange-profile list' to see available profiles"
    fi
    exit 0
fi

# If we get here, it's a profile switch request
PROFILE="$COMMAND"

# Extract valid profile names from profiles.json using basic shell tools
VALID_PROFILES=$(grep '"name"' "$PROFILES_FILE" | sed 's/.*"name": *"\([^"]*\)".*/\1/' 2>/dev/null)

if [ -z "$VALID_PROFILES" ]; then
    echo "❌ Error: Failed to parse profiles.json or no profiles found"
    exit 1
fi

# Check if the provided profile is valid
if ! echo "$VALID_PROFILES" | grep -q "^$PROFILE$"; then
    echo "❌ Invalid profile: '$PROFILE'"
    echo ""
    echo "Available profiles: $(echo "$VALID_PROFILES" | tr '\n' ' ')"
    echo ""
    echo "Commands: /ai-exchange-profile list | current | <profile>"
    exit 1
fi

# Read current config
current_config=$(cat ~/.claude.json)

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to read ~/.claude.json"
    exit 1
fi

# Update the GW_PROFILE for mcp-adaptor server using sed
# Create a backup first
cp ~/.claude.json ~/.claude.json.backup

# Check if mcp-adaptor exists in the config
if ! grep -q '"mcp-adaptor"' ~/.claude.json; then
    echo "❌ Error: mcp-adaptor server not found in configuration"
    exit 1
fi

# Use sed to update the GW_PROFILE value
# This finds the line with "GW_PROFILE" and replaces its value
sed -i.tmp 's/"GW_PROFILE": *"[^"]*"/"GW_PROFILE": "'"$PROFILE"'"/' ~/.claude.json

# Check if the replacement was successful
if grep -q '"GW_PROFILE": *"'"$PROFILE"'"' ~/.claude.json; then
    echo "✅ Profile switched to: $PROFILE"
    rm -f ~/.claude.json.tmp ~/.claude.json.backup
    echo ""
    echo "⚠️  Restart Claude Code to activate the new profile:"
    echo "   1. Run '/exit'"
    echo "   2. Restart Claude Code"
else
    echo "❌ Failed to update profile"
    mv ~/.claude.json.backup ~/.claude.json
    rm -f ~/.claude.json.tmp
    exit 1
fi
```

**Profile Context**: You are now working with the "$ARGUMENTS" profile.

**Available AI Exchange Profiles:**
```bash
echo "Available AI Exchange Profiles:"
echo ""
grep -A 1 '"name":' "$PROFILES_FILE" | grep -E '"name"|"description"' | sed 'N;s/.*"name": *"\([^"]*\)".*\n.*"description": *"\([^"]*\)".*/• \1: \2/' | while read line; do
    echo "  $line"
done
```

**Domain-Specific Tools**: The "$ARGUMENTS" profile provides specialized MCP tools and capabilities tailored for its specific domain.

**Expert Knowledge**: You now have access to deep understanding of the workflows, patterns, and best practices specific to the "$ARGUMENTS" profile's technology stack.

**Contextual Assistance**: All help will be tailored to the specific use cases and challenges relevant to the "$ARGUMENTS" profile.

The configuration change sets the `GW_PROFILE` environment variable in your mcp-adaptor server configuration, which loads the appropriate tools and capabilities for the "$ARGUMENTS" profile.

How can I assist you with the "$ARGUMENTS" profile now that it's been activated?
