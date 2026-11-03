# MCP Server Integration Rule

## Rule ID: cursor-rules/mcp-integration
## Priority: High

### Description
When using AI-assisted development with Cursor or other MCP-compatible IDEs, properly configure the MCP server connection for the Cloudinary asset management SDK.

### Guidelines
- Create a `.cursor/mcp.json` file in the project root with the MCP server configuration
- Use the `npx` approach to load `@cloudinary/asset-management` package
- Pass API credentials as command-line arguments: `--api-key`, `--api-secret`, `--cloud-name`
- Restart the IDE after creating/updating the `.cursor/mcp.json` configuration
- Only call transformation-related tools after consulting the `get-tx-reference` documentation
- Call the `get-tx-reference` tool only once per session - documentation doesn't change

### Anti-Patterns
- ❌ Omitting the `.cursor/mcp.json` configuration file
- ❌ Hardcoding credentials in the MCP configuration
- ❌ Calling `get-tx-reference` multiple times in the same session
- ❌ Attempting transformations without first consulting the transformation rules documentation

### Example
```json
// .cursor/mcp.json
{
  "mcpServers": {
    "cloudinary-asset-mgmt": {
      "command": "npx",
      "args": [
        "-y",
        "--package",
        "@cloudinary/asset-management",
        "--",
        "mcp",
        "start",
        "--api-key",
        "YOUR_API_KEY",
        "--api-secret",
        "YOUR_API_SECRET",
        "--cloud-name",
        "YOUR_CLOUD_NAME"
      ]
    }
  }
}
```