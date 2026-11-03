# Error Handling Rule

## Rule ID: cursor-rules/error-handling
## Priority: High

### Description
All API calls must implement proper try-catch error handling with meaningful error messages. Use the custom error classes provided by the SDK.

### Guidelines
- Wrap all SDK operations in try-catch blocks
- Use the SDK's custom error classes for type-safe error handling
- Check for specific error codes/messages when handling different error scenarios
- Provide user-friendly error messages while logging detailed error information
- For MCP server operations, handle connection errors gracefully

### Anti-Patterns
- ❌ Omitting try-catch blocks for API calls
- ❌ Using generic `Error` type instead of SDK-specific error types
- ❌ Logging raw error objects without sanitization
- ❌ Ignoring error return values

### Example
```typescript
import client from "./cloudinary-client";

async function safeUpload(filePath: string) {
  try {
    const result = await client.upload.upload("auto", { file: filePath });
    console.log("Asset uploaded:", result.public_id);
    return result;
  } catch (error) {
    console.error("Upload failed:", error instanceof Error ? error.message : error);
    throw error;
  }
}
```