# Access Control Types Rule

## Rule ID: cursor-rules/access-control
## Priority: High

### Description
All access control operations must use the proper `AccessControl`, `AccessControlToken`, or `AccessControlAnonymous` types with their respective inbound/outbound schemas. Never use raw objects or strings for access control.

### Guidelines
- Use `AccessControl$inboundSchema` for parsing incoming requests
- Use `AccessControl$outboundSchema` for serializing responses
- Use `accessControlToJSON()` and `accessControlFromJSON()` for JSON conversion
- The `AccessControlAnonymousAccessType` const defines the anonymous type: `{ Anonymous: "anonymous" }`
- All upload operations (`upload()`, `uploadChunk()`, `uploadText()`, `uploadNoResourceType()`) accept an `access_control` parameter of type `Array<AccessControl$inboundSchema>`
- All list/get operations return `access_control` in responses as `Array<AccessControl$Outbound>`

### Anti-Patterns
- ❌ Directly assigning `{ raw: "true" }` as accessControl
- ❌ Omitting the access_control parameter when access control is needed
- ❌ Using deprecated `access_mode` parameter instead of `access_control`

### Example
```typescript
import { accessControlToJSON, accessControlFromJSON } from "@cloudinary/asset-management";

// Creating access control
const myAccessControl: AccessControl = {
  // ... access control properties
};

const jsonString = accessControlToJSON(myAccessControl);
const parsed = accessControlFromJSON(jsonString);
```