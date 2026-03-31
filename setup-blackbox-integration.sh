#!/bin/bash

# Cloudinary Asset Management SDK - BLACKBOX AI Integration Setup Script
# This script sets up the complete integration in your BLACKBOX AI environment

set -e

echo "🚀 Cloudinary Asset Management SDK - BLACKBOX AI Integration Setup"
echo "=================================================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Step 1: Check Node.js installation
echo "📋 Checking prerequisites..."
if ! command -v node &> /dev/null; then
  print_error "Node.js is not installed"
  echo "Install Node.js v18+ from https://nodejs.org"
  exit 1
fi
NODE_VERSION=$(node -v)
print_status "Node.js $NODE_VERSION found"

# Step 2: Get Cloudinary credentials
echo ""
echo "🔐 Setting up Cloudinary credentials..."
echo "Get these from https://cloudinary.com/console/settings/api-keys"
echo ""

read -p "Enter your Cloudinary Cloud Name: " CLOUD_NAME
if [ -z "$CLOUD_NAME" ]; then
  print_error "Cloud name is required"
  exit 1
fi

read -p "Enter your API Key: " API_KEY
if [ -z "$API_KEY" ]; then
  print_error "API Key is required"
  exit 1
fi

read -sp "Enter your API Secret: " API_SECRET
echo ""
if [ -z "$API_SECRET" ]; then
  print_error "API Secret is required"
  exit 1
fi

print_status "Credentials received"

# Step 3: Create .env file
echo ""
echo "📝 Creating .env file..."

# Backup existing .env
if [ -f ".env" ]; then
  print_warning ".env already exists, creating backup as .env.backup"
  cp .env .env.backup
fi

cat > .env << EOF
CLOUDINARY_CLOUD_NAME=$CLOUD_NAME
CLOUDINARY_API_KEY=$API_KEY
CLOUDINARY_API_SECRET=$API_SECRET
EOF

chmod 600 .env
print_status ".env file created (readable only by you)"

# Step 4: Add to .gitignore
echo ""
echo "🔒 Securing .env file..."

if [ -f ".gitignore" ]; then
  if grep -q "\.env" .gitignore; then
    print_status ".env already in .gitignore"
  else
    echo ".env" >> .gitignore
    print_status "Added .env to .gitignore"
  fi
else
  echo ".env" > .gitignore
  echo ".env.*.local" >> .gitignore
  echo "dist/" >> .gitignore
  echo "node_modules/" >> .gitignore
  print_status "Created .gitignore"
fi

# Step 5: Install dependencies
echo ""
echo "📦 Installing @cloudinary/asset-management..."

if command -v npm &> /dev/null; then
  npm install @cloudinary/asset-management zod
  print_status "Package installed successfully"
elif command -v yarn &> /dev/null; then
  yarn add @cloudinary/asset-management zod
  print_status "Package installed successfully (using yarn)"
elif command -v pnpm &> /dev/null; then
  pnpm add @cloudinary/asset-management zod
  print_status "Package installed successfully (using pnpm)"
elif command -v bun &> /dev/null; then
  bun add @cloudinary/asset-management
  print_status "Package installed successfully (using bun)"
else
  print_error "No package manager found"
  exit 1
fi

# Step 6: Test credentials
echo ""
echo "🧪 Testing credentials..."

cat > test-credentials.mjs << 'EOF'
import { CloudinaryAssetMgmt } from "@cloudinary/asset-management";
import * as fs from "fs";
import * as path from "path";

// Load .env
const envPath = path.join(process.cwd(), ".env");
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, "utf-8");
  envContent.split("\n").forEach((line) => {
    const [key, ...values] = line.split("=");
    if (key && values.length > 0) {
      process.env[key.trim()] = values.join("=").trim();
    }
  });
}

const client = new CloudinaryAssetMgmt({
  cloudName: process.env.CLOUDINARY_CLOUD_NAME,
  security: {
    cloudinaryAuth: {
      apiKey: process.env.CLOUDINARY_API_KEY,
      apiSecret: process.env.CLOUDINARY_API_SECRET,
    },
  },
});

try {
  const usage = await client.usage.getUsage();
  console.log("✓ Credentials verified!");
  console.log(`Account: ${usage.objects || 0} objects`);
  console.log(`Storage: ${Math.round((usage.bytes || 0) / 1024 / 1024)}MB`);
  process.exit(0);
} catch (error) {
  console.error("✗ Credentials failed:", error.message);
  process.exit(1);
}
EOF

node test-credentials.mjs
TEST_RESULT=$?

rm test-credentials.mjs

if [ $TEST_RESULT -eq 0 ]; then
  print_status "Credentials verified!"
else
  print_error "Credential test failed"
  exit 1
fi

# Step 7: Configure MCP (ask user's environment)
echo ""
echo "🤖 Configuring MCP Server (for Claude, Cursor, etc.)..."
read -p "Which IDE are you using? (claude/cursor/other): " IDE_CHOICE

case $IDE_CHOICE in
  claude|Claude)
    echo ""
    echo "📝 Add this to ~/.claude/claude_desktop_config.json:"
    echo ""
    cat << CLAUDE_CONFIG
{
  "mcpServers": {
    "cloudinary-asset-mgmt": {
      "command": "npx",
      "args": [
        "-y",
        "--package", "@cloudinary/asset-management",
        "--",
        "mcp", "start",
        "--api-key", "$API_KEY",
        "--api-secret", "$API_SECRET",
        "--cloud-name", "$CLOUD_NAME"
      ]
    }
  }
}
CLAUDE_CONFIG
    print_warning "After updating config, restart Claude Desktop"
    ;;
  cursor|Cursor)
    echo ""
    echo "📝 Create .cursor/mcp.json with:"
    echo ""
    cat << CURSOR_CONFIG
{
  "mcpServers": {
    "cloudinary-asset-mgmt": {
      "command": "npx",
      "args": [
        "-y",
        "--package", "@cloudinary/asset-management",
        "--",
        "mcp", "start",
        "--api-key", "$API_KEY",
        "--api-secret", "$API_SECRET",
        "--cloud-name", "$CLOUD_NAME"
      ]
    }
  }
}
CURSOR_CONFIG
    print_warning "After creating config, restart Cursor"
    ;;
  *)
    echo "See BLACKBOX_AI_INTEGRATION.md for detailed MCP setup instructions"
    ;;
esac

# Step 8: Summary
echo ""
echo "=================================================================="
echo "✅ Setup Complete!"
echo "=================================================================="
echo ""
echo "📂 What was created:"
echo "  • .env - Your Cloudinary credentials"
echo "  • node_modules - SDK and dependencies"
echo "  • Updated .gitignore"
echo ""
echo "📚 Documentation files created:"
echo "  • BLACKBOX_AI_SKILL.md - Complete API reference"
echo "  • BLACKBOX_AI_INTEGRATION.md - Integration guide"
echo "  • blackbox-skill.yaml - Skill manifest"
echo ""
echo "🚀 Next steps:"
echo "  1. Review BLACKBOX_AI_INTEGRATION.md for detailed setup"
echo "  2. Configure your IDE (Claude/Cursor) if using MCP"
echo "  3. Read BLACKBOX_AI_SKILL.md for operation examples"
echo "  4. Start using Cloudinary in your BLACKBOX AI!"
echo ""
echo "🔗 Resources:"
echo "  • Dashboard: https://cloudinary.com/console"
echo "  • Documentation: https://cloudinary.com/documentation"
echo "  • API Reference: https://cloudinary.com/documentation/admin_api"
echo ""
