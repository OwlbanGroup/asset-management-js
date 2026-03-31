# BLACKBOX AI Integration Guide
## Cloudinary Asset Management SDK

Complete instructions for integrating the Cloudinary Asset Management SDK into your BLACKBOX AI environment.

---

## Table of Contents

1. [Overview](#overview)
2. [Pre-Integration Setup](#pre-integration-setup)
3. [Integration Methods](#integration-methods)
4. [Verification & Testing](#verification--testing)
5. [Usage in BLACKBOX AI](#usage-in-blackbox-ai)
6. [Advanced Configuration](#advanced-configuration)
7. [Troubleshooting](#troubleshooting)

---

## Overview

This integration adds comprehensive Cloudinary asset management capabilities to BLACKBOX AI, enabling the AI to:

✅ **Upload & Manage Assets** - Images, videos, documents  
✅ **Search & Discover** - Full-text and visual search  
✅ **Organize** - Folders, tags, metadata, relationships  
✅ **Analyze** - Video analytics, usage statistics  
✅ **Automate** - Batch operations, transformations  
✅ **Moderate** - Content review and approval workflows  

**45+ Operations** across 10 functional areas, with complete TypeScript support.

---

## Pre-Integration Setup

### Step 1: Get Cloudinary Credentials

1. Sign up for free at https://cloudinary.com
2. Go to **Dashboard** → **Settings** → **API Keys**
3. Copy these values:
   - **Cloud Name** - Your unique identifier
   - **API Key** - Public key for requests
   - **API Secret** - Secret key (keep private!)

### Step 2: Install Package

```bash
# Using npm
npm install @cloudinary/asset-management zod

# Using yarn
yarn add @cloudinary/asset-management zod

# Using pnpm
pnpm add @cloudinary/asset-management zod

# Using bun
bun add @cloudinary/asset-management
```

### Step 3: Set Environment Variables

Create a `.env` file in your project:

```env
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

Never commit these to version control! Add to `.gitignore`:

```
.env
.env.local
.env.*.local
```

---

## Integration Methods

### Method 1: Direct SDK Integration (Recommended for Development)

**Best for:** Local development, testing, scripting

#### Step 1: Initialize Client

Create `cloudinary-client.ts`:

```typescript
import { CloudinaryAssetMgmt } from "@cloudinary/asset-management";

const client = new CloudinaryAssetMgmt({
  cloudName: process.env.CLOUDINARY_CLOUD_NAME || "",
  security: {
    cloudinaryAuth: {
      apiKey: process.env.CLOUDINARY_API_KEY || "",
      apiSecret: process.env.CLOUDINARY_API_SECRET || "",
    },
  },
});

export default client;
```

#### Step 2: Use in Your Code

```typescript
import client from "./cloudinary-client";

// Upload example
async function uploadAsset(filePath: string) {
  const result = await client.upload.upload("auto", {
    file: filePath,
    tags: ["ai-generated", new Date().toISOString()],
  });
  
  console.log("Asset uploaded:", result.public_id);
  return result;
}

// Search example
async function searchAssets(query: string) {
  const results = await client.search.searchAssets({
    query,
    maxResults: 50,
  });
  
  return results.resources;
}

export { uploadAsset, searchAssets };
```

---

### Method 2: MCP Server Integration (Recommended for AI)

**Best for:** AI agents, BLACKBOX AI integration, Claude, Cursor

#### Step 1: Install MCP Server

Node.js v20+ required:

```bash
npm install -g @cloudinary/asset-management
```

Or use npx directly without installation.

#### Step 2: Configure for Claude Desktop

Edit `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "cloudinary-asset-mgmt": {
      "command": "npx",
      "args": [
        "-y",
        "--package", "@cloudinary/asset-management",
        "--",
        "mcp", "start",
        "--api-key", "YOUR_API_KEY",
        "--api-secret", "YOUR_API_SECRET",
        "--cloud-name", "YOUR_CLOUD_NAME"
      ]
    }
  }
}
```

**On macOS/Linux:**
```bash
~/.claude/claude_desktop_config.json
```

**On Windows:**
```bash
%APPDATA%\Claude\claude_desktop_config.json
```

#### Step 3: Configure for Cursor

Create `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "cloudinary-asset-mgmt": {
      "command": "npx",
      "args": [
        "-y",
        "--package", "@cloudinary/asset-management",
        "--",
        "mcp", "start",
        "--api-key", "YOUR_API_KEY",
        "--api-secret", "YOUR_API_SECRET",
        "--cloud-name", "YOUR_CLOUD_NAME"
      ]
    }
  }
}
```

#### Step 4: Restart IDE

- **Claude Desktop**: Restart the application
- **Cursor**: Restart the IDE
- **VS Code**: Reload window (Cmd/Ctrl+R)

---

### Method 3: Custom MCP Server (Advanced)

**Best for:** Self-hosted deployments, enterprise setups

#### Create MCP Server

Create `src/mcp-server.ts`:

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { CloudinaryAssetMgmt } from "@cloudinary/asset-management";

const client = new CloudinaryAssetMgmt({
  cloudName: process.env.CLOUDINARY_CLOUD_NAME || "",
  security: {
    cloudinaryAuth: {
      apiKey: process.env.CLOUDINARY_API_KEY || "",
      apiSecret: process.env.CLOUDINARY_API_SECRET || "",
    },
  },
});

const server = new Server({
  name: "cloudinary-asset-mgmt",
  version: "0.5.9",
});

// List all available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "upload_asset",
        description: "Upload file to Cloudinary",
        inputSchema: {
          type: "object" as const,
          properties: {
            file: { type: "string", description: "File path" },
            tags: { type: "array", items: { type: "string" } },
            format: { type: "string", description: "Output format" },
          },
          required: ["file"],
        },
      },
      {
        name: "search_assets",
        description: "Search assets in Cloudinary",
        inputSchema: {
          type: "object" as const,
          properties: {
            query: { type: "string" },
            maxResults: { type: "number" },
          },
          required: ["query"],
        },
      },
      {
        name: "list_assets",
        description: "List assets by type",
        inputSchema: {
          type: "object" as const,
          properties: {
            type: {
              type: "string",
              enum: ["images", "videos", "raw"],
            },
            maxResults: { type: "number" },
          },
          required: ["type"],
        },
      },
      // Add more tools...
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request;

  switch (name) {
    case "upload_asset":
      const uploadResult = await client.upload.upload("auto", {
        file: args.file,
        tags: args.tags || [],
        format: args.format || undefined,
      });
      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify(uploadResult, null, 2),
          },
        ],
      };

    case "search_assets":
      const searchResult = await client.search.searchAssets({
        query: args.query,
        maxResults: args.maxResults || 50,
      });
      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify(searchResult, null, 2),
          },
        ],
      };

    case "list_assets":
      let listResult;
      if (args.type === "images") {
        listResult = await client.assets.listImages({
          maxResults: args.maxResults || 50,
        });
      } else if (args.type === "videos") {
        listResult = await client.assets.listVideos({
          maxResults: args.maxResults || 50,
        });
      } else {
        listResult = await client.assets.listRawFiles({
          maxResults: args.maxResults || 50,
        });
      }
      return {
        content: [
          {
            type: "text" as const,
            text: JSON.stringify(listResult, null, 2),
          },
        ],
      };

    default:
      return {
        content: [{ type: "text" as const, text: `Unknown tool: ${name}` }],
        isError: true,
      };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

#### Build & Deploy

```bash
# Build
npm run build

# Run
node dist/mcp-server.js
```

---

## Verification & Testing

### Test 1: Check Credentials

Run this to verify your credentials work:

```typescript
import client from "./cloudinary-client";

async function testCredentials() {
  try {
    const usage = await client.usage.getUsage();
    console.log("✅ Credentials verified!");
    console.log("Account: ", usage);
  } catch (error) {
    console.error("❌ Credentials failed:", error);
  }
}

testCredentials();
```

Expected output:
```
✅ Credentials verified!
Account: {
  objects: 1234,
  bytes: 5678900000,
  ...
}
```

### Test 2: Upload Test

```typescript
import client from "./cloudinary-client";

async function testUpload() {
  try {
    const result = await client.upload.upload("auto", {
      file: "./test-image.jpg",
      tags: ["test"],
    });
    console.log("✅ Upload successful!");
    console.log("Public ID:", result.public_id);
    console.log("URL:", result.secure_url);
  } catch (error) {
    console.error("❌ Upload failed:", error);
  }
}

testUpload();
```

### Test 3: MCP Server Test

```bash
# Start MCP server
npx @cloudinary/asset-management mcp start \
  --api-key YOUR_API_KEY \
  --api-secret YOUR_API_SECRET \
  --cloud-name YOUR_CLOUD_NAME

# Expected output:
# Server listening on stdio
# Ready to accept tool calls
```

---

## Usage in BLACKBOX AI

### Asking BLACKBOX AI to Use the Integration

Once configured, you can ask:

```
"Upload this image file to Cloudinary"
"Search for all images tagged with 'product'"
"Create a folder and organize my assets"
"Generate a ZIP archive of selected assets"
"Get video analytics for the last 30 days"
```

### Example Prompts

**Prompt 1: Batch Upload**
```
"Upload all JPG files from the uploads folder to Cloudinary with tags 'batch-2024' and 'product'"
```

**Prompt 2: Smart Search**
```
"Find all images in my Cloudinary account that have the tag 'approved' and were created in the last month"
```

**Prompt 3: Organization**
```
"Create a folder structure like: Projects > 2024 > Q1 > Marketing, then move all marketing assets there"
```

**Prompt 4: Analytics**
```
"Get video view counts for all videos created this month, grouped by day"
```

**Prompt 5: Content Moderation**
```
"List all assets pending moderation, show me the first 10, and update them to approved if they look good"
```

---

## Advanced Configuration

### Rate Limiting & Retries

Configure automatic retry behavior:

```typescript
const client = new CloudinaryAssetMgmt({
  cloudName: "your-cloud",
  security: { ... },
  retries: 3,           // Retry failed requests
  timeout: 30000,       // 30 second timeout
});
```

### Webhook Notifications

Get notified when operations complete:

```typescript
const result = await client.upload.upload("auto", {
  file: "./large-video.mp4",
  notification_url: "https://your-domain.com/webhooks/cloudinary",
  eager_async: true,    // Process asynchronously
});
```

### Custom Headers

Add custom headers to requests:

```typescript
const result = await client.upload.upload("auto", {
  file: "./image.jpg",
  headers: "X-Custom-Header: value",
});
```

### Debugging

Enable debug logging:

```typescript
const client = new CloudinaryAssetMgmt({
  cloudName: "your-cloud",
  security: { ... },
  debug: true,  // Enable detailed logging
});
```

---

## Troubleshooting

### Issue: "401 Unauthorized"

**Cause:** Invalid API key or secret

**Solution:**
```bash
# Verify credentials in environment variables
echo $CLOUDINARY_API_KEY
echo $CLOUDINARY_API_SECRET
echo $CLOUDINARY_CLOUD_NAME

# Test with correct values
```

### Issue: "404 Not Found"

**Cause:** Asset doesn't exist or wrong public_id format

**Solution:**
```typescript
// Verify asset exists before operations
const asset = await client.assets.getResourceByPublicId({
  publicId: "your-public-id"
}).catch(e => {
  console.log("Asset not found:", e);
  return null;
});
```

### Issue: "429 Too Many Requests"

**Cause:** Rate limiting (max requests per minute)

**Solution:**
```typescript
// Implement exponential backoff
async function withRetry(fn, maxAttempts = 3) {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429 && attempt < maxAttempts - 1) {
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
      } else {
        throw error;
      }
    }
  }
}
```

### Issue: "File too large"

**Cause:** Single file upload exceeds limit

**Solution:**
```typescript
// Use chunked upload for large files
const result = await client.upload.uploadChunk({
  file: largeFile,
  chunkSize: 20_000_000, // 20MB chunks
});
```

### Issue: MCP Tools Not Appearing

**Cause:** Server not configured correctly

**Solution:**
1. Verify `claude_desktop_config.json` path is correct
2. Check credentials in config
3. Restart IDE completely
4. Check for typos in server name

```bash
# On macOS/Linux, verify path:
cat ~/.claude/claude_desktop_config.json | jq .

# On Windows:
type %APPDATA%\Claude\claude_desktop_config.json
```

### Issue: Slow Uploads

**Cause:** Large files, network latency

**Solution:**
```typescript
// Use chunked upload with optimization
const result = await client.upload.uploadChunk({
  file: largeFile,
  chunkSize: 20_000_000,
  timeout: 60000, // 60 second timeout
});
```

---

## Next Steps

1. ✅ **Complete setup** - Run verification tests
2. 📚 **Review examples** - Check `/examples` folder
3. 🚀 **Start using** - Begin with simple operations
4. 📖 **Read documentation** - Review BLACKBOX_AI_SKILL.md
5. 🔧 **Customize** - Adapt to your workflow
6. 📊 **Monitor** - Check Cloudinary dashboard for usage

---

## Support Resources

| Resource | URL |
|----------|-----|
| **Official Docs** | https://cloudinary.com/documentation |
| **API Reference** | https://cloudinary.com/documentation/admin_api |
| **GitHub Repository** | https://github.com/cloudinary/asset-management-js |
| **Issue Tracker** | https://github.com/cloudinary/asset-management-js/issues |
| **Support Portal** | https://support.cloudinary.com |
| **Community Forum** | https://cloudinary.com/community |

---

## Quick Reference

### Common Operations

| Task | Code |
|------|------|
| Upload file | `client.upload.upload("auto", { file })` |
| Search assets | `client.search.searchAssets({ query })` |
| Get asset | `client.assets.getResourceByPublicId({ publicId })` |
| Update metadata | `client.assets.updateResourceByPublicId({ publicId, tags })` |
| Delete asset | `client.upload.destroyAsset({ publicId })` |
| Create folder | `client.folders.createFolder({ displayName })` |
| List images | `client.assets.listImages({ maxResults })` |
| Get usage | `client.usage.getUsage()` |

### Environment Setup (Copy-Paste)

```bash
# 1. Install package
npm install @cloudinary/asset-management zod

# 2. Create .env
echo "CLOUDINARY_CLOUD_NAME=your-cloud-name" > .env
echo "CLOUDINARY_API_KEY=your-api-key" >> .env
echo "CLOUDINARY_API_SECRET=your-api-secret" >> .env

# 3. Add to .gitignore
echo ".env" >> .gitignore

# 4. Verify
node -e "require('dotenv').config(); console.log('Cloud:', process.env.CLOUDINARY_CLOUD_NAME)"
```

---

**Version:** 1.0  
**Last Updated:** 2024  
**SDK Version:** 0.5.9
