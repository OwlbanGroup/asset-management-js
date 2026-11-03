# API Authentication Rule

## Rule ID: cursor-rules/api-authentication
## Priority: High

### Description
All API calls must use proper authentication via environment variables. Never hardcode Cloudinary credentials in source code.

### Guidelines
- Create a `.env` file in the project root with:
  - `CLOUDINARY_CLOUD_NAME=your-cloud-name`
  - `CLOUDINARY_API_KEY=your-api-key`
  - `CLOUDINARY_API_SECRET=your-api-secret`
- Never commit `.env` files to version control (add to `.gitignore`)
- Use `process.env.CLOUDINARY_CLOUD_NAME`, `process.env.CLOUDINARY_API_KEY`, and `process.env.CLOUDINARY_API_SECRET` for configuration
- Initialize `CloudinaryAssetMgmt` client with proper security configuration
- For MCP server integration, pass `--api-key`, `--api-secret`, and `--cloud-name` as command line arguments

### Anti-Patterns
- ❌ Hardcoding API credentials in source code
- ❌ Committing `.env` files to git
- ❌ Using default or placeholder credentials in production

### Example
```typescript
// cloudinary-client.ts
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