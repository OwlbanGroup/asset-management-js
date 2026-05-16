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

## Advanced Workflows

### Workflow 1: Automated Content Moderation Pipeline

This workflow automates the entire content moderation process:

```typescript
import { CloudinaryAssetMgmt } from "@cloudinary/asset-management";

const client = new CloudinaryAssetMgmt({
  cloudName: process.env.CLOUDINARY_CLOUD_NAME,
  security: { cloudinaryAuth: {
    apiKey: process.env.CLOUDINARY_API_KEY,
    apiSecret: process.env.CLOUDINARY_API_SECRET,
  }},
});

// Step 1: Fetch pending moderation items
async function fetchPendingModeration() {
  return await client.assets.listResourcesByModerationKindAndStatus({
    kind: "cloudinary_ml",
    status: "pending",
    maxResults: 100,
  });
}

// Step 2: Review and update status
async function reviewAsset(publicId: string, approved: boolean) {
  await client.assets.updateResourceByPublicId({
    publicId,
    moderation_status: approved ? "approved" : "rejected",
    context: {
      reviewed_at: new Date().toISOString(),
      reviewed_by: "automated-pipeline",
    },
  });
}

// Step 3: Process batch
async function processModerationBatch() {
  const pending = await fetchPendingModeration();
  
  for (const asset of pending.resources) {
    // Add your ML model classification here
    const classification = await classifyContent(asset);
    await reviewAsset(asset.public_id, classification.safe);
  }
  
  return { processed: pending.resources.length };
}
```

### Workflow 2: Dynamic Image Transformation Pipeline

Real-time image optimization and transformation:

```typescript
// Upload with automatic transformations
async function uploadWithTransformations(filePath: string, options: any) {
  return await client.upload.upload("image", {
    file: filePath,
    eager: [
      // Thumbnail for mobile
      { width: 150, height: 150, crop: "fill", gravity: "auto", 
        quality: "auto", fetch_format: "auto" },
      // Medium resolution
      { width: 800, height: 600, crop: "limit", 
        quality: "auto", fetch_format: "auto" },
      // High resolution for download
      { quality: "auto:best", fetch_format: "original" },
    ],
    eager_async: true,
    eager_notification_url: options.webhookUrl,
  });
}

// Generate transformed URLs on-demand
function getTransformedUrl(publicId: string, transformation: string) {
  return `https://res.cloudinary.com/${process.env.CLOUDINARY_CLOUD_NAME}/image/upload/${transformation}/${publicId}`;
}

// Example transformations
const transformations = {
  thumbnail: "c_fill,w_150,h_150,g_auto,q_auto,f_auto",
  medium: "c_limit,w_800,h_600,q_auto,f_auto", 
  high: "q_best,f_original",
  social: "c_fill,w_1200,h_630,g_auto,q_auto,f_auto",
};
```

### Workflow 3: Batch Asset Organization

Organize large asset collections automatically:

```typescript
interface AssetBatch {
  files: string[];
  folder: string;
  tags: string[];
}

// Create organized folder structure
async function createFolderStructure(baseName: string, year: string) {
  const yearFolder = await client.folders.createFolder({
    displayName: `${baseName}_${year}`,
  });
  
  const quarters = ["Q1", "Q2", "Q3", "Q4"];
  const subfolders = {};
  
  for (const q of quarters) {
    const folder = await client.folders.createFolder({
      displayName: q,
      parentFolderId: yearFolder.id,
    });
    subfolders[q] = folder.id;
  }
  
  return { yearFolder, subfolders };
}

// Batch upload to organized folders
async function batchUploadAssets(batch: AssetBatch) {
  const results = [];
  
  for (const file of batch.files) {
    const result = await client.upload.upload("auto", {
      file,
      folder: batch.folder,
      tags: [...batch.tags, `uploaded_${new Date().toISOString().split('T')[0]}`],
    });
    results.push(result);
  }
  
  return results;
}

// Organize by file type
async function organizeByType(baseFolder: string) {
  const typeFolders = {
    images: await client.folders.createFolder({ displayName: `${baseFolder}_images` }),
    videos: await client.folders.createFolder({ displayName: `${baseFolder}_videos` }),
    documents: await client.folders.createFolder({ displayName: `${baseFolder}_documents` }),
    raw: await client.folders.createFolder({ displayName: `${baseFolder}_raw` }),
  };
  
  // Get all assets without folder assignment
  const allImages = await client.assets.listImages({ maxResults: 500 });
  const allVideos = await client.assets.listVideos({ maxResults: 500 });
  
  // Move to appropriate folders
  for (const img of allImages.resources) {
    await client.assets.updateResourceByPublicId({
      publicId: img.public_id,
      folder: typeFolders.images.id,
    });
  }
  
  return { organized: allImages.resources.length + allVideos.resources.length };
}
```

### Workflow 4: Video Processing Pipeline

Complete video upload and processing workflow:

```typescript
interface VideoOptions {
  file: string;
  publicId?: string;
  tags?: string[];
  webhookUrl?: string;
}

// Upload video with multiple formats
async function uploadVideoWithProcessing(options: VideoOptions) {
  return await client.upload.upload("video", {
    file: options.file,
    public_id: options.publicId,
    tags: options.tags,
    eager: [
      // HLS format for streaming
      {
        streaming_profile: "hd",
        format: "m3u8",
        resource_type: "video",
      },
      // Thumbnail at 10% duration
      {
        start_offset: "10%",
        width: 640,
        height: 360,
        crop: "fill",
        format: "jpg",
        resource_type: "image",
      },
    ],
    eager_async: true,
    notification_url: options.webhookUrl,
  });
}

// Get video analytics summary
async function getVideoAnalyticsSummary(publicIds: string[]) {
  const analytics = [];
  
  for (const pid of publicIds) {
    const views = await client.videoAnalytics.getVideoViews({
      publicId: pid,
      startDate: "2024-01-01",
      endDate: new Date().toISOString().split('T')[0],
      groupBy: "day",
    });
    analytics.push({ publicId: pid, views });
  }
  
  return analytics;
}

// Generate video thumbnail sprite
async function generateThumbnailSprite(publicId: string, count: number = 10) {
  return await client.upload.upload("video", {
    file: `cloudinary://${publicId}`,
    eager: Array.from({ length: count }, (_, i) => ({
      timestamp: `${i * 10}%`,
      width: 160,
      height: 90,
      crop: "fill",
      format: "jpg",
      resource_type: "image",
    })),
    eager_async: true,
  });
}
```

### Workflow 5: Search and Filter Intelligence

Advanced search patterns for asset discovery:

```typescript
// Complex search queries
async function advancedSearch(options: {
  query: string;
  sortBy?: string;
  direction?: "asc" | "desc";
  maxResults?: number;
}) {
  return await client.search.searchAssets({
    query: options.query,
    sortBy: { field: options.sortBy || "created_at", direction: options.direction || "desc" },
    maxResults: options.maxResults || 50,
  });
}

// Search templates
const searchQueries = {
  recentImages: "resource_type:image AND created_at:[now-7d TO now]",
  highResolution: "resource_type:image AND bytes:>5000000",
  untagged: "tags:empty",
  approvedPhotos: "resource_type:image AND moderation_status:approved",
  byContext: (key: string, value: string) => `context:${key}:${value}`,
  byDateRange: (start: string, end: string) => `created_at:[${start} TO ${end}]`,
  largeFiles: "bytes:>10000000",
  videoOnly: "resource_type:video",
};

// Faceted search for statistics
async function getAssetStatistics() {
  const stats = {
    totalImages: await advancedSearch({ query: "resource_type:image" }),
    totalVideos: await advancedSearch({ query: "resource_type:video" }),
    totalRaw: await advancedSearch({ query: "resource_type:raw" }),
    pendingModeration: await advancedSearch({ query: "moderation_status:pending" }),
  };
  return stats;
}

// Visual similarity search
async function findSimilarAssets(imageUrl: string, maxResults: number = 20) {
  return await client.search.visualSearchAssets({
    imageUrl,
    maxResults,
  });
}
```

### Workflow 6: Backup and Archive Management

Automated backup and archive workflows:

```typescript
// Create scheduled archive
async function createScheduledArchive(targetPublicIds: string[], archiveName: string) {
  return await client.assets.generateArchive({
    targetPublicIds,
    archiveType: "zip",
    format: "zip",
    metadata: {
      created_by: "automation",
      scheduled_at: new Date().toISOString(),
      archive_name: archiveName,
    },
  });
}

// Download asset with backup
async function downloadWithBackup(publicId: string) {
  const asset = await client.assets.getResourceByPublicId({ publicId });
  const backup = await client.assets.downloadBackupAsset({
    publicId,
    version: asset.version,
  });
  
  return { asset, backup };
}

// Version management
async function listAssetVersions(publicId: string) {
  const versions = [];
  const current = await client.assets.getResourceByPublicId({ publicId });
  
  for (let v = 1; v <= current.version; v++) {
    const versioned = await client.assets.getResourceByPublicId({
      publicId,
      version: v,
    });
    versions.push(versioned);
  }
  
  return versions;
}
```

### Workflow 7: Real-time Webhook Processing

Handle webhook notifications for events:

```typescript
// Webhook endpoint handler (Express)
import express from "express";
const app = express();
app.use(express.json());

interface WebhookEvent {
  public_id: string;
  event: string;
  timestamp: number;
  api_key: string;
}

// Handle upload completion
app.post("/webhooks/upload", async (req, res) => {
  const event: WebhookEvent = req.body;
  
  if (event.event === "upload success") {
    // Process uploaded file
    await client.assets.updateResourceByPublicId({
      publicId: event.public_id,
      tags: [...req.body.tags, "webhook-processed"],
    });
  }
  
  res.status(200).json({ received: true });
});

// Handle transformation completion
app.post("/webhooks/transformation", async (req, res) => {
  const event = req.body;
  
  if (event.event === "transformation success") {
    // Notify downstream systems
    console.log(`Transformation complete: ${event.public_id}`);
  }
  
  res.status(200).json({ received: true });
});

// Handle archive completion
app.post("/webhooks/archive", async (req, res) => {
  const event = req.body;
  
  if (event.event === "archive created") {
    // Send archive link to user
    console.log(`Archive ready: ${event.archive_url}`);
  }
  
  res.status(200).json({ received: true });
});
```

### Workflow 8: Concurrent Operations

Parallel processing for better performance:

```typescript
import { Promise } from "promise";

// Concurrent uploads
async function concurrentUploads(files: string[], options: any) {
  const uploadPromises = files.map(file =>
    client.upload.upload("auto", { file, ...options })
  );
  return await Promise.all(uploadPromises);
}

// Concurrent searches
async function concurrentSearches(queries: string[]) {
  const searchPromises = queries.map(query =>
    client.search.searchAssets({ query })
  );
  return await Promise.all(searchPromises);
}

// Batch delete with concurrency
async function batchDelete(publicIds: string[], batchSize: number = 10) {
  const results = [];
  
  for (let i = 0; i < publicIds.length; i += batchSize) {
    const batch = publicIds.slice(i, i + batchSize);
    const deletePromises = batch.map(pid =>
      client.upload.destroyAsset({ publicId: pid }).catch(e => ({ error: e.message, pid }))
    );
    const batchResults = await Promise.all(deletePromises);
    results.push(...batchResults);
  }
  
  return results;
}

// Concurrent folder creation
async function createFolderBatch(folders: string[], parentId?: string) {
  const createPromises = folders.map(name =>
    client.folders.createFolder({ displayName: name, parentFolderId: parentId })
  );
  return await Promise.all(createPromises);
}
```

### Workflow 9: Error Recovery

Robust error handling and retry logic:

```typescript
// Retry decorator
async function withRetry<T>(
  fn: () => Promise<T>,
  maxAttempts: number = 3,
  delay: number = 1000
): Promise<T> {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error: any) {
      if (attempt === maxAttempts) throw error;
      
      // Exponential backoff
      const waitTime = delay * Math.pow(2, attempt - 1);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
  throw new Error("Max retries exceeded");
}

// Circuit breaker
class CircuitBreaker {
  private failures = 0;
  private lastFailure: number = 0;
  private state: "closed" | "open" | "half-open" = "closed";
  
  constructor(
    private threshold: number = 5,
    private timeout: number = 30000
  ) {}
  
  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === "open") {
      if (Date.now() - this.lastFailure > this.timeout) {
        this.state = "half-open";
      } else {
        throw new Error("Circuit breaker is open");
      }
    }
    
    try {
      const result = await fn();
      if (this.state === "half-open") {
        this.state = "closed";
        this.failures = 0;
      }
      return result;
    } catch (error) {
      this.failures++;
      this.lastFailure = Date.now();
      
      if (this.failures >= this.threshold) {
        this.state = "open";
      }
      throw error;
    }
  }
}

// Graceful degradation
async function getAssetWithFallback(publicId: string) {
  try {
    return await client.assets.getResourceByPublicId({ publicId });
  } catch (error) {
    console.error("Primary fetch failed, trying backup:", error);
    
    try {
      return await client.assets.getResourceByAssetId({
        assetId: publicId.replace("upload/", "")
      });
    } catch (backupError) {
      console.error("Backup also failed:", backupError);
      return null;
    }
  }
}
```

### Workflow 10: Metadata Management

Advanced metadata operations:

```typescript
// Set rich metadata
async function setRichMetadata(publicId: string, metadata: {
  title: string;
  description: string;
  author: string;
  license: string;
  tags: string[];
}) {
  return await client.assets.updateResourceByPublicId({
    publicId,
    context: {
      title: metadata.title,
      description: metadata.description,
      author: metadata.author,
      license: metadata.license,
    },
    tags: metadata.tags,
  });
}

// Query by metadata
async function queryByMetadata(key: string, value: string) {
  return await client.assets.listResourcesByContext({
    context: { key, value },
  });
}

// Bulk metadata update
async function bulkMetadataUpdate(
  assetIds: string[],
  updates: { tags?: string[]; context?: Record<string, string> }
) {
  const results = [];
  
  for (const assetId of assetIds) {
    const result = await client.assets.updateResourceByAssetId({
      assetId,
      tags: updates.tags,
      context: updates.context,
    });
    results.push(result);
  }
  
  return results;
}

// Metadata-driven transformations
async function getMetadataDrivenUrl(publicId: string, metadata: any) {
  let transformation = "c_fill,w_800,h_600";
  
  if (metadata.aspect_ratio === "16:9") {
    transformation = "c_fill,w_1280,h_720";
  } else if (metadata.aspect_ratio === "4:3") {
    transformation = "c_fill,w_1024,h_768";
  }
  
  if (metadata.quality === "high") {
    transformation += ",q_auto:best";
  } else if (metadata.quality === "low") {
    transformation += ",q_auto:eco";
  }
  
  return `https://res.cloudinary.com/${process.env.CLOUDINARY_CLOUD_NAME}/image/upload/${transformation}/${publicId}`;
}
```

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

**Version:** 1.1  
**Last Updated:** 2025  
**SDK Version:** 0.5.9

---

## Recommended Additional Features

### Feature 1: Upload Presets

Configure automatic optimization presets:

```typescript
const uploadPresets = {
  thumbnail: { width: 150, height: 150, crop: "fill", gravity: "auto", quality: "auto" },
  social: { width: 1200, height: 630, crop: "fill", quality: "auto" },
  highQuality: { quality: "auto:best", fetch_format: "original" },
  optimized: { quality: "auto", fetch_format: "auto", progressive: true }
};

async function uploadWithPreset(filePath: string, preset: string) {
  return await client.upload.upload("auto", { file: filePath, ...uploadPresets[preset] });
}
```

### Feature 2: Asset Tagging Automation

Auto-tag assets based on content:

```typescript
async function autoTagAssets(publicIds: string[]) {
  const results = [];
  for (const pid of publicIds) {
    const result = await client.assets.updateResourceByPublicId({
      publicId: pid,
      autoTagging: 0.7, // Enable auto-tagging with 70% confidence
    });
    results.push(result);
  }
  return results;
}
```

### Feature 3: Signed URLs

Generate secure signed URLs:

```typescript
function generateSignedUrl(publicId: string, expiresIn: number = 3600) {
  const timestamp = Math.floor(Date.now() / 1000) + expiresIn;
  return `https://res.cloudinary.com/${process.env.CLOUDINARY_CLOUD_NAME}/image/upload/${publicId}?sign=${timestamp}`;
}
```

### Feature 4: Progress Tracking

Track upload progress for large files:

```typescript
async function uploadWithProgress(file: File, onProgress: (p: number) => void) {
  return await client.upload.uploadChunk({
    file,
    chunkSize: 20_000_000,
    onProgress: (progress) => onProgress(progress.loaded / progress.total * 100)
  });
}
```

### Feature 5: Cache Invalidation

Purge CDN cache for updated assets:

```typescript
async function invalidateAsset(publicId: string) {
  return await client.upload.destroyAsset({ publicId, invalidate: true });
}
```

### Feature 6: Usage Alerts

Set up usage monitoring:

```typescript
async function checkUsageAndAlert(threshold: number = 0.9) {
  const usage = await client.usage.getUsage();
  const usagePercent = usage.objects / 100000; // Assuming 100k limit
  
  if (usagePercent > threshold) {
    console.warn(`⚠️ Usage at ${(usagePercent * 100).toFixed(1)}% of limit!`);
  }
  return usage;
}
```

### Feature 7: Batch Processing with Rate Limiting

Process large batches without hitting rate limits:

```typescript
async function batchProcess<T>(
  items: T[],
  processor: (item: T) => Promise<any>,
  batchSize: number = 10,
  delayMs: number = 1000
) {
  const results = [];
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const batchResults = await Promise.all(batch.map(processor));
    results.push(...batchResults);
    if (i + batchSize < items.length) {
      await new Promise(resolve => setTimeout(resolve, delayMs));
    }
  }
  return results;
}
```

### Feature 8: Conditional Updates

Update only if conditions are met:

```typescript
async function conditionalUpdate(publicId: string, updates: any, conditions: any) {
  const current = await client.assets.getResourceByPublicId({ publicId }).catch(() => null);
  
  if (!current) return null;
  if (conditions.updatedBefore && new Date(current.updated_at) > conditions.updatedBefore) {
    return { skipped: true, reason: "already_updated" };
  }
  
  return await client.assets.updateResourceByPublicId({ publicId, ...updates });
}
```

### Feature 9: Asset Validation

Validate asset before operations:

```typescript
async function validateAsset(publicId: string) {
  const asset = await client.assets.getResourceByPublicId({ publicId })
    .catch(() => null);
  
  if (!asset) return { valid: false, reason: "not_found" };
  if (asset.bytes > 100_000_000) return { valid: false, reason: "too_large" };
  if (asset.resource_type === "video" && !asset.duration) return { valid: false, reason: "processing" };
  
  return { valid: true, asset };
}
```

### Feature 10: Health Check

Monitor integration health:

```typescript
async function healthCheck() {
  const checks = {
    api: false,
    credentials: false,
    upload: false,
    search: false
  };
  
  try {
    const usage = await client.usage.getUsage();
    checks.credentials = !!usage;
    checks.api = true;
  } catch (e) { /* not connected */ }
  
  return { healthy: checks.api && checks.credentials, checks };
}
```
