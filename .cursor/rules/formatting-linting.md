# Code Formatting & Linting Rule

## Rule ID: cursor-rules/formatting-linting
## Priority: Medium

### Description
Maintain consistent code formatting and adhere to linting rules to ensure code quality and readability.

### Guidelines
- Run `npm run lint` (eslint --cache --max-warnings=0 src) before committing changes
- Run `npm run format` (prettier --write src/) to format code
- Run `npm run format:check` (prettier --check src/) to check formatting
- Fix all linting warnings before pushing changes
- Ensure code adheres to the project's existing style conventions

### Anti-Patterns
- ❌ Committing code without running lint checks
- ❌ Ignoring linting warnings or errors
- ❌ Formatting code inconsistently across the codebase
- ❌ Using deprecated or removed linting rules

### Example Commands
```bash
# Lint check
npm run lint

# Format code
npm run format

# Check formatting
npm run format:check
```