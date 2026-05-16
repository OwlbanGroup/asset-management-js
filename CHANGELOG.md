# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- Initial BLACKBOX AI integration support
- MCP server configuration for AI integration
- BLACKBOX_AI_SKILL.md with complete API documentation
- BLACKBOX_AI_INTEGRATION.md setup guide
- blackbox-skill.yaml machine-readable manifest
- Automated setup scripts (setup-blackbox-integration.sh/bat)

### Changed

- Project renamed to @cloudinary/asset-management
- Updated package.json with proper exports configuration
- Enhanced TypeScript support with comprehensive types

### Fixed

- Fixed export configuration for dual ESM/CommonJS support

### Dependencies

- Added @modelcontextprotocol/sdk as peer dependency
- Updated zod dependency version

---

## [0.5.9] - 2024-XX-XX

### Added

- Complete Cloudinary Asset Management SDK
- 45+ operations for asset management
- Full MCP server support
- Comprehensive TypeScript types
- Error handling with custom error classes

### Operations

#### Asset Upload (5 operations)

- `upload()` - Upload files (images, videos, documents)
- `uploadChunk()` - Upload large files in chunks
- `uploadText()` - Upload text content as asset
- `uploadNoResourceType()` - Upload without specifying resource type
- `destroyAsset()` - Delete uploaded asset

#### Asset Retrieval (6 operations)

- `getResourceByAssetId()` - Get asset by internal asset ID
- `getResourceByPublicId()` - Get asset by public ID
- `listImages()` - List all images in account
- `listVideos()` - List all videos in account
- `listRawFiles()` - List all raw files
- `listResourcesByAssetFolder()` - List assets in specific folder

#### Search & Discovery (2 operations)

- `searchAssets()` - Full-text search across assets
- `visualSearchAssets()` - Find similar assets using visual similarity

#### Asset Updates (3 operations)

- `updateResourceByPublicId()` - Update asset metadata, tags, and status
- `updateResourceByAssetId()` - Update asset by asset ID
- `renameAsset()` - Change asset public ID

#### Deletion & Restoration (4 operations)

- `deleteResourcesByPublicId()` - Batch delete assets by public ID
- `restoreResourcesByAssetIDs()` - Restore deleted assets
- `deleteBackupVersions()` - Delete backup versions
- `destroyByAssetId()` - Delete asset by asset ID

#### Folders (7 operations)

- `createFolder()` - Create new folder
- `destroyFolder()` - Delete folder
- `listRootFolders()` - List top-level folders
- `showFolder()` - Get folder details
- `updateFolder()` - Update folder properties
- `searchFolders()` - Search folders by name
- `searchFoldersPost()` - Search folders (POST method)

#### Asset Relationships (4 operations)

- `createAssetRelationsByPublicId()` - Link related assets
- `createAssetRelationsByAssetId()` - Link assets by asset ID
- `deleteAssetRelationsByPublicId()` - Remove asset relationships
- `deleteAssetRelationsByAssetId()` - Remove relationships by asset ID

#### Advanced Operations (8 operations)

- `downloadAsset()` - Download asset file
- `generateArchive()` - Create ZIP/TAR archive
- `explicitAsset()` - Pre-generate transformations
- `listResourceTags()` - Get all tags in account
- `listResourceTypes()` - Get resource type statistics
- `derivedDestroy()` - Delete derived versions
- `listResourcesByAssetIDs()` - Get multiple assets by IDs
- `listResourcesByContext()` - Filter assets by metadata

#### Moderation (1 operation)

- `listResourcesByModerationKindAndStatus()` - List by moderation status

#### Analytics (1 operation)

- `getVideoViews()` - Get video analytics and view count

#### Usage (1 operation)

- `getUsage()` - Get account usage and quota statistics

---

## [0.5.0] - 2024-01-01

### Added

- Initial release
- Basic Cloudinary asset management functionality
- SDK core with authentication hooks
- MCP server for local development

---

## Release Procedure

To create a new release:

1. Update version in package.json
2. Add new entry to CHANGELOG.md with date
3. Commit changes with message: "Release vX.Y.Z"
4. Create git tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
5. Push: `git push && git push --tags`

### Version Numbering

Given a version number MAJOR.MINOR.PATCH:

- MAJOR: Incompatible API changes
- MINOR: New functionality (backwards compatible)
- PATCH: Bug fixes (backwards compatible)

### Pre-release Versions

- alpha: Alpha release (experimental)
- beta: Beta release (testing)
- rc: Release candidate (final testing)

Example: `0.6.0-alpha.1`, `0.6.0-beta.1`, `0.6.0-rc.1`

---

## Deprecation Policy

When deprecating functionality:

1. Announce deprecation in CHANGELOG.md
2. Add deprecation warning in code
3. Provide alternative in documentation
4. Maintain deprecated code for at least 2 minor versions
5. Remove in next major version

---

## Migration Guides

### Upgrading from 0.4.x to 0.5.x

1. Update import statements
2. Review new operation signatures
3. Update authentication configuration
4. Test all integrations

---

## Credits

- Cloudinary SDK Team
- Contributors and community members

---

## License

MIT License - See [LICENSE](LICENSE) file for details

---

**Note**: This project follows [Keep a Changelog](https://keepachangelog.com) guidelines.
