# Cloudinary Asset Management SDK - BLACKBOX AI Skill

**Skill ID:** cloudinary-asset-management  
**Version:** 0.5.9  
**Category:** Cloud Services, Asset Management, API Integration  
**Author:** Cloudinary  
**License:** MIT

---

## Overview

The Cloudinary Asset Management JavaScript SDK provides comprehensive programmatic access to Cloudinary's asset management APIs. This skill enables AI agents to help developers integrate Cloudinary asset management capabilities into their applications, including asset upload, manipulation, organization, search, and administration.

### Key Capabilities

- **Asset Upload & Management**: Upload, transform, and manage digital assets (images, videos, documents)
- **Asset Organization**: Create folders, manage asset relationships and tags
- **Search & Discovery**: Full-text search, visual search, asset listing and filtering
- **Asset Restoration & Backup**: Restore deleted assets, manage backup versions
- **Video Analytics**: Track video performance metrics
- **Moderation**: Integrate automated content moderation
- **Batch Operations**: Handle multiple assets efficiently
- **MCP Server Integration**: Deploy as a Model Context Protocol server for AI applications

---

## Installation & Setup

### Package Installation

```bash
# npm
npm add @cloudinary/asset-management zod

# pnpm
pnpm add @cloudinary/asset-management zod

# bun
bun add @cloudinary/asset-management

# yarn
yarn add @cloudinary/asset-management zod
```

### Minimum Requirements

- **Node.js**: v18.0.0 or higher (v20+ for MCP server)
- **Dependencies**: zod (for TypeScript type validation)

### Basic Configuration

```typescript
import { CloudinaryAssetMgmt } from "@cloudinary/asset-management";

const client = new CloudinaryAssetMgmt({
  cloudName: "your-cloud-name",
  security: {
    cloudinaryAuth: {
      apiKey: "YOUR_API_KEY",
      apiSecret: "YOUR_API_SECRET",
    },
  },
});
```

### Environment Variables

```bash
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

### MCP Server Configuration

#### Claude Desktop (claude_desktop_config.json)
```json
{
  "mcpServers": {
    "cloudinary-asset-mgmt": {
      "command": "npx",
      "args": [
        "-y", "--package", "@cloudinary/asset-management",
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

#### Cursor (.cursor/mcp.json)
```json
{
  "mcpServers": {
    "cloudinary-asset-mgmt": {
      "command": "npx",
      "args": [
        "-y", "--package", "@cloudinary/asset-management",
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

---

## Authentication

### API Authentication Methods

1. **Cloud Credentials** (Recommended for server-side)
   ```typescript
   security: {
     cloudinaryAuth: {
       apiKey: "your-api-key",
       apiSecret: "your-api-secret"
     }
   }
   ```

2. **OAuth Token** (For third-party applications)
   ```typescript
   security: {
     cloudinaryOAuth: {
       oAuthToken: "your-oauth-token"
     }
   }
   ```

### Getting Credentials

1. Log into [Cloudinary Dashboard](https://cloudinary.com/console)
2. Navigate to **Settings** → **API Keys**
3. Copy your **Cloud Name**, **API Key**, and **API Secret**
4. Store in environment variables (never hardcode credentials)

---

## Core Operations Reference

### Asset Upload Operations

#### Basic File Upload
```typescript
const result = await client.upload.upload("auto", {
  file: "/path/to/file.jpg",
  format: "jpg",
  quality: "auto",
});
```

**Operation:** `assetUpload`  
**Method:** `client.upload.upload(type, options)`  
**Parameters:**
- `type`: "auto" | "image" | "video" | "raw"
- `options`: Upload options object

**Key Options:**
- `file`: File path or buffer
- `format`: Output format (jpg, png, webp, pdf, etc.)
- `quality`: Image quality (0-100 or "auto")
- `allowedFormats`: Comma-separated list of allowed formats
- `beforeUpload`: Custom pre-processing
- `rawConvert`: Format conversion (e.g., "google_speech:vtt:en-US")
- `backgroundRemoval`: "pixelz" or other background removal services
- `autoTagging`: Confidence threshold (0.0-1.0) for auto-tagging
- `detection`: Detection model (e.g., "coco_v2" for object detection)
- `moderation`: Moderation service ("google_video_moderation", "explicit", "cloudinary_ml")

**Returns:** Upload response with asset metadata and public_id

#### Chunked Upload
```typescript
const result = await client.upload.uploadChunk({
  file: largeFile,
  chunkSize: 20_000_000, // 20MB chunks
});
```

**Operation:** `assetUploadChunk`  
**Use Case:** Large files (videos, large images)  
**Parameters:** File, chunk size, upload options

---

### Asset Retrieval Operations

#### Get Single Asset by ID
```typescript
const asset = await client.assets.getResourceByAssetId({
  assetId: "asset-id-uuid",
});
```

**Operation:** `assetsGetResourceByAssetId`  
**Returns:** Complete asset metadata and properties

#### Get Asset by Public ID
```typescript
const asset = await client.assets.getResourceByPublicId({
  publicId: "folder/filename",
  type: "upload", // "upload", "private", "authenticated"
  version: 5, // optional specific version
});
```

**Operation:** `assetsGetResourceByPublicId`  
**Parameters:**
- `publicId`: Asset's public identifier
- `type`: Asset type (default: "upload")
- `version`: Specific version number

---

### Asset Listing & Search

#### List Images
```typescript
const images = await client.assets.listImages({
  maxResults: 100,
  prefix: "folder/", // optional filter
});
```

**Operation:** `assetsListImages`  
**Returns:** Paginated list of image assets

#### List Videos
```typescript
const videos = await client.assets.listVideos({
  maxResults: 50,
});
```

**Operation:** `assetsListVideos`  
**Returns:** Paginated list of video assets

#### List by Context
```typescript
const assets = await client.assets.listResourcesByContext({
  context: { key: "campaign_id", value: "summer_2024" },
  maxResults: 100,
});
```

**Operation:** `assetsListResourcesByContext`  
**Use Case:** Filter assets by custom metadata

#### Full-Text Search
```typescript
const results = await client.search.searchAssets({
  query: "filename:product AND tags:active",
  maxResults: 50,
  sort: { field: "created_at", direction: "desc" },
});
```

**Operation:** `searchSearchAssets`  
**Query Syntax:**
- `filename:pattern` - Search by filename
- `tags:tag_name` - Filter by tags
- `asset_id:id` - Search by asset ID
- `context:key:value` - Search by metadata
- Combined: `filename:photo AND tags:vacation`

#### Visual Search
```typescript
const results = await client.search.visualSearchAssets({
  imageUrl: "https://example.com/image.jpg",
  maxResults: 20,
});
```

**Operation:** `searchVisualSearchAssets`  
**Use Case:** Find similar images using visual similarity

---

### Asset Update & Modification

#### Update Asset Metadata
```typescript
const updated = await client.assets.updateResourceByPublicId({
  publicId: "folder/filename",
  tags: ["new-tag-1", "new-tag-2"],
  context: { key1: "value1", key2: "value2" },
  metadata: { field1: "value1" },
  moderation_status: "approved",
});
```

**Operation:** `assetsUpdateResourceByPublicId`  
**Updatable Fields:**
- `tags`: Array of tag strings
- `context`: Custom key-value metadata
- `metadata`: Additional structured metadata
- `moderation_status`: "pending", "approved", "rejected"
- `notification_url`: Webhook URL for events

#### Rename Asset
```typescript
const result = await client.assets.renameAsset({
  fromPublicId: "old-folder/old-name",
  toPublicId: "new-folder/new-name",
  type: "upload",
  overwrite: true, // Replace if exists
});
```

**Operation:** `assetsRenameAsset`  
**Important:** Updating public_id is an expensive operation

---

### Asset Deletion & Restoration

#### Delete Asset
```typescript
const result = await client.upload.destroyAsset({
  publicId: "folder/filename",
  type: "upload",
  invalidate: true, // Purge CDN cache
});
```

**Operation:** `uploadDestroyAsset`  
**Parameters:**
- `publicId`: Asset to delete
- `type`: Asset type
- `invalidate`: Clear CDN cache

#### Delete Multiple Assets
```typescript
const result = await client.assets.deleteResourcesByPublicId({
  publicIds: ["path/file1", "path/file2", "path/file3"],
  type: "upload",
  invalidate: true,
});
```

**Operation:** `assetsDeleteResourcesByPublicId`  
**Use Case:** Batch deletion of up to 100 assets

#### Restore Deleted Asset
```typescript
const result = await client.assets.restoreResourcesByAssetIDs({
  assetIds: ["asset-id-1", "asset-id-2"],
});
```

**Operation:** `assetsRestoreResourcesByAssetIDs`  
**Note:** Only works during 30-day recovery window

---

### Folder Management

#### Create Folder
```typescript
const folder = await client.folders.createFolder({
  displayName: "My Folder",
  parentFolderId: "parent-id", // optional
});
```

**Operation:** `foldersCreateFolder`  
**Returns:** Folder object with ID and properties

#### List Root Folders
```typescript
const folders = await client.folders.listRootFolders({
  maxResults: 100,
});
```

**Operation:** `foldersListRootFolders`

#### Search Folders
```typescript
const results = await client.folders.searchFolders({
  displayName: "My%", // LIKE pattern matching
  maxResults: 50,
});
```

**Operation:** `foldersSearchFolders`  
**Note:** Uses SQL LIKE pattern syntax (% = wildcard)

#### Update Folder
```typescript
const updated = await client.folders.updateFolder({
  parentFolderId: "folder-id",
  displayName: "Updated Name",
});
```

**Operation:** `foldersUpdateFolder`

#### Delete Folder
```typescript
const result = await client.folders.destroyFolder({
  parentFolderId: "folder-id",
});
```

**Operation:** `foldersDestroyFolder`

---

### Asset Relationships & Tags

#### Create Asset Relations
```typescript
const relation = await client.assetRelations.createAssetRelationsByPublicId({
  publicId: "main-asset",
  relatedAssetPublicIds: ["related-1", "related-2"],
  relationType: "derived_from", // or other relation types
});
```

**Operation:** `assetRelationsCreateAssetRelationsByPublicId`  
**Use Cases:**
- Link derived assets to originals
- Link variants and transformations
- Create asset families

#### Delete Asset Relations
```typescript
const result = await client.assetRelations.deleteAssetRelationsByPublicId({
  publicId: "asset",
  relatedAssetPublicIds: ["related"],
  relationType: "derived_from",
});
```

**Operation:** `assetRelationsDeleteAssetRelationsByPublicId`

#### List Resource Tags
```typescript
const tags = await client.assets.listResourceTags({
  prefix: "tag-", // optional filter
  maxResults: 100,
});
```

**Operation:** `assetsListResourceTags`  
**Returns:** All tags in account with usage counts

---

### Advanced Asset Operations

#### Download Asset
```typescript
const buffer = await client.assets.downloadAsset({
  publicId: "folder/filename",
  type: "upload",
  version: 1,
});
```

**Operation:** `assetsDownloadAsset`  
**Returns:** Asset buffer for processing

#### Generate Archive
```typescript
const archiveId = await client.assets.generateArchive({
  targetPublicIds: ["file1", "file2", "file3"],
  archiveType: "zip", // or "tar"
  format: "zip",
});
```

**Operation:** `assetsGenerateArchive`  
**Returns:** Archive download URL

#### Explicit Asset Configuration
```typescript
const result = await client.assets.explicitAsset({
  publicId: "folder/filename",
  type: "upload",
  eager: [
    {
      width: 300,
      height: 300,
      crop: "fill",
      gravity: "face",
      radius: "max",
      quality: "auto:good",
      fetch_format: "auto",
    },
  ],
  eager_async: false,
  invalidate: true,
});
```

**Operation:** `assetsExplicitAsset`  
**Use Case:** Pre-generate transformations without manual requests

---

### Video Analytics

#### Get Video Views
```typescript
const analytics = await client.videoAnalytics.getVideoViews({
  publicId: "folder/video",
  startDate: "2024-01-01",
  endDate: "2024-01-31",
  groupBy: "day", // "hour", "day", "week", "month"
});
```

**Operation:** `videoAnalyticsGetVideoViews`  
**Returns:** Video view data and analytics

---

### Moderation & Safety

#### List Moderation Status
```typescript
const moderated = await client.assets.listResourcesByModerationKindAndStatus({
  kind: "google_video_moderation", // or "explicit", "cloudinary_ml"
  status: "pending", // "pending", "approved", "rejected"
  maxResults: 100,
});
```

**Operation:** `assetsListResourcesByModerationKindAndStatus`  
**Use Cases:**
- Review pending moderations
- Find rejected/approved assets
- Compliance monitoring

---

### Usage & Quotas

#### Get Usage Statistics
```typescript
const usage = await client.usage.getUsage();
```

**Operation:** `usageGetUsage`  
**Returns:**
- Objects count
- Video transformations
- Bandwidth & storage usage
- Requests used
- Limits and quotas

---

## Type Definitions

### Core Types

```typescript
// Asset metadata
interface CloudinaryResource {
  public_id: string;
  asset_id: string;
  version: number;
  created_at: string;
  updated_at: string;
  resource_type: "image" | "video" | "raw";
  type: "upload" | "private" | "authenticated";
  bytes: number;
  width?: number;
  height?: number;
  format: string;
  url: string;
  secure_url: string;
  tags: string[];
  context?: Record<string, string>;
  metadata?: Record<string, string>;
  moderation_status?: "pending" | "approved" | "rejected";
}

// Upload response
interface UploadResponse {
  public_id: string;
  asset_id: string;
  version: number;
  signature: string;
  width?: number;
  height?: number;
  format: string;
  resource_type: string;
  created_at: string;
  tags: string[];
  bytes: number;
  type: string;
  url: string;
  secure_url: string;
  folder: string;
  original_filename: string;
}

// Search results
interface SearchResponse {
  total_count: number;
  resources: CloudinaryResource[];
  next_cursor?: string;
}

// Folder
interface Folder {
  id: string;
  parent_folder_id: string;
  display_name: string;
  created_at: string;
  path: string;
}

// Asset relationship
interface AssetRelation {
  asset_id: string;
  related_asset_id: string;
  relation_type: string;
}
```

---

## Error Handling

### Error Types

```typescript
try {
  const result = await client.upload.upload("auto", options);
} catch (error) {
  if (error.status === 400) {
    // Bad request (invalid parameters)
  } else if (error.status === 401) {
    // Authentication failed
  } else if (error.status === 403) {
    // Forbidden (permission denied)
  } else if (error.status === 404) {
    // Asset not found
  } else if (error.status === 409) {
    // Conflict (duplicate public_id)
  } else if (error.status === 429) {
    // Rate limited
  } else if (error.status === 500) {
    // Server error
  }
}
```

### Best Practices

1. **Always use try-catch** for API calls
2. **Implement exponential backoff** for rate limiting (429)
3. **Validate inputs** before sending to API
4. **Use specific error messages** for logging
5. **Implement retry logic** for transient failures
6. **Store credentials safely** in environment variables

---

## Common Patterns & Best Practices

### Pattern 1: Organization with Folders
```typescript
// Create folder structure
const jobFolder = await client.folders.createFolder({
  displayName: `job_${jobId}_{timestamp}`,
});

// Upload to folder
const asset = await client.upload.upload("auto", {
  file: filePath,
  folder: jobFolder.id,
  tags: [jobType, "processed"],
});
```

### Pattern 2: Batch Operations
```typescript
// Upload multiple files
const uploads = await Promise.all(
  files.map(file =>
    client.upload.upload("auto", {
      file,
      tags: ["batch_import", timestamp],
    })
  )
);

// Delete multiple assets
if (toDelete.length > 0) {
  await client.assets.deleteResourcesByPublicId({
    publicIds: toDelete,
    invalidate: true,
  });
}
```

### Pattern 3: Search & Filter
```typescript
// Find all approved assets with specific tag
const approved = await client.search.searchAssets({
  query: "tags:approved AND created_at:[2024-01-01 TO 2024-12-31]",
  maxResults: 100,
  sort: { field: "created_at", direction: "desc" },
});

// Paginate results
let cursor = undefined;
let allResults = [];
do {
  const batch = await client.search.searchAssets({
    query: "resource_type:video",
    maxResults: 100,
    cursor: cursor,
  });
  allResults = allResults.concat(batch.resources);
  cursor = batch.next_cursor;
} while (cursor);
```

### Pattern 4: Asset Versioning
```typescript
// Store version information
const asset = await client.upload.upload("auto", {
  file: newVersion,
  publicId: productId,
  overwrite: true,
  tags: [`v${versionNumber}`, "current"],
});

// Restore previous version
const oldAsset = await client.assets.getResourceByPublicId({
  publicId: productId,
  version: previousVersionNumber,
});
```

### Pattern 5: Conditional Updates
```typescript
// Update only if asset exists
const existing = await client.assets.getResourceByPublicId({
  publicId: "path/file",
}).catch(() => null);

if (existing) {
  await client.assets.updateResourceByPublicId({
    publicId: "path/file",
    tags: [...existing.tags, "updated"],
    moderation_status: "approved",
  });
}
```

---

## Debugging & Logging

### Enable HTTP Debugging
```typescript
const client = new CloudinaryAssetMgmt({
  cloudName: "your-cloud",
  security: { ... },
  debug: true, // Enable debug logging
});
```

### Check Response Headers
```typescript
const result = await client.upload.upload("auto", options);
console.log({
  headers: result.headers,
  status: result.status,
  body: result.data,
});
```

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Invalid credentials | Verify API key & secret |
| 403 Forbidden | Missing permissions | Check account plan limits |
| 404 Not Found | Asset doesn't exist | Verify public_id format |
| 409 Conflict | Duplicate public_id | Use different name or overwrite: true |
| 429 Rate Limited | Too many requests | Implement exponential backoff |
| File too large | Exceeds limit | Use chunked upload for >100MB |

---

## SDK as MCP Server

This SDK can be deployed as a Model Context Protocol (MCP) server, making all operations available as tools for AI agents.

### Starting the Server
```bash
npx @cloudinary/asset-management mcp start \
  --api-key YOUR_API_KEY \
  --api-secret YOUR_API_SECRET \
  --cloud-name YOUR_CLOUD_NAME
```

### Available Tools in MCP Server
All SDK operations are exposed as tools:
- **upload__upload** - Upload files
- **assets__get_resource_by_public_id** - Get asset metadata
- **search__search_assets** - Search and filter
- **folders__create_folder** - Create folder
- **asset_relations__create_asset_relations_by_public_id** - Link assets
- ... and 40+ more operations

### Integration with AI Applications
```json
{
  "mcpServers": {
    "cloudinary": {
      "command": "node",
      "args": ["./mcp-server.js"],
      "env": {
        "CLOUDINARY_API_KEY": "...",
        "CLOUDINARY_API_SECRET": "...",
        "CLOUDINARY_CLOUD_NAME": "..."
      }
    }
  }
}
```

---

## API Reference Quick Links

### Asset Operations (28 functions)
- Create relations, delete, download, explicit config
- List: images, videos, tags, types, by folder, by context
- Get: by asset ID, by public ID
- Rename, restore, update, derive, generate archive
- Backup versions, moderation status

### Folder Operations (7 functions)
- Create, destroy, list root, search, show, update

### Upload Operations (5 functions)
- Basic upload, chunked upload, destroy, text upload
- Upload without resource type

### Search Operations (2 functions)
- Standard search with query language
- Visual/similarity search

### Relationships (4 functions)
- Create, delete by asset ID or public ID

### Other Operations
- Video analytics (views, engagement)
- Usage statistics and quotas

---

## Learn More

- **Official Docs**: https://cloudinary.com/documentation
- **API Reference**: https://cloudinary.com/documentation/admin_api
- **GitHub Repository**: https://github.com/cloudinary/asset-management-js
- **Examples**: See `/examples` directory in repository
- **Type Definitions**: Full TypeScript support included

---

## Support & Troubleshooting

### Getting Help

1. **Check Documentation**: Review USAGE.md and README.md
2. **Review Examples**: `/examples` directory has working code
3. **GitHub Issues**: Report bugs at https://github.com/cloudinary/asset-management-js/issues
4. **Cloudinary Support**: https://support.cloudinary.com

### Development Setup

```bash
# Install dependencies
npm install

# Run linting
npm run lint

# Build SDK
npm run build

# Build MCP server
npm run build:mcp
```

---

## Version History

- **0.5.9** - Current version with full API support
- See **RELEASES.md** for detailed changelog

---

**Last Updated:** 2024
**Maintained by:** Cloudinary  
**License:** MIT
