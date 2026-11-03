# TypeScript Type Safety Rule

## Rule ID: cursor-rules/typescript-types
## Priority: High

### Description
All code must leverage the full TypeScript type support provided by the SDK. Never bypass type checking or use `any` types indiscriminately.

### Guidelines
- Import types from `@cloudinary/asset-management` rather than hardcoding interfaces
- Use the provided Zod schemas for input validation (`AccessControl$inboundSchema`, `UploadRequest$inboundSchema`, etc.)
- Leverage the generated TypeScript types for all operation responses
- Enable strict TypeScript mode (`"strict": true` in tsconfig.json)
- Type-check the codebase regularly using `npm run lint` or `bun test`

### Anti-Patterns
- ❌ Using `type: "any"` for operation parameters or responses
- ❌ Bypassing TypeScript checks with `// @ts-ignore` comments
- ❌ Not providing types for custom extensions or modifications
- ❌ Ignoring TypeScript compilation errors

### Example
```typescript
// Correct: Use provided types
import { AccessControl } from "@cloudinary/asset-management";

// Incorrect: Bypassing types
const result: any = await client.assets.upload("public_id", { file: "path" });
```