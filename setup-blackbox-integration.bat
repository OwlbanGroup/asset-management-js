@echo off
setlocal enabledelayedexpansion

REM Cloudinary Asset Management SDK - BLACKBOX AI Integration Setup Script
REM This script sets up the complete integration on Windows

echo.
echo Cloudinary Asset Management SDK - BLACKBOX AI Integration Setup
echo ================================================================
echo.

REM Check Node.js installation
echo Checking prerequisites...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [X] Node.js is not installed
    echo Install Node.js v18+ from https://nodejs.org
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo [√] Node.js %NODE_VERSION% found
echo.

REM Get Cloudinary credentials
echo Setting up Cloudinary credentials...
echo Get these from https://cloudinary.com/console/settings/api-keys
echo.

set /p CLOUD_NAME="Enter your Cloudinary Cloud Name: "
if "%CLOUD_NAME%"=="" (
    echo [X] Cloud name is required
    pause
    exit /b 1
)

set /p API_KEY="Enter your API Key: "
if "%API_KEY%"=="" (
    echo [X] API Key is required
    pause
    exit /b 1
)

set /p API_SECRET="Enter your API Secret: "
if "%API_SECRET%"=="" (
    echo [X] API Secret is required
    pause
    exit /b 1
)

echo [√] Credentials received
echo.

REM Create .env file
echo Creating .env file...

if exist ".env" (
    echo [!] .env already exists, creating backup as .env.backup
    copy .env .env.backup >nul
)

(
    echo CLOUDINARY_CLOUD_NAME=%CLOUD_NAME%
    echo CLOUDINARY_API_KEY=%API_KEY%
    echo CLOUDINARY_API_SECRET=%API_SECRET%
) > .env

echo [√] .env file created
echo.

REM Add to .gitignore
echo Securing .env file...

if exist ".gitignore" (
    findstr /m "\.env" .gitignore >nul
    if %errorlevel% equ 0 (
        echo [√] .env already in .gitignore
    ) else (
        echo .env>> .gitignore
        echo [√] Added .env to .gitignore
    )
) else (
    (
        echo .env
        echo .env.*.local
        echo dist/
        echo node_modules/
    ) > .gitignore
    echo [√] Created .gitignore
)

echo.

REM Install dependencies
echo Installing @cloudinary/asset-management...

where npm >nul 2>nul
if %errorlevel% equ 0 (
    call npm install @cloudinary/asset-management zod
    echo [√] Package installed successfully
) else (
    where yarn >nul 2>nul
    if %errorlevel% equ 0 (
        call yarn add @cloudinary/asset-management zod
        echo [√] Package installed successfully (using yarn)
    ) else (
        where pnpm >nul 2>nul
        if %errorlevel% equ 0 (
            call pnpm add @cloudinary/asset-management zod
            echo [√] Package installed successfully (using pnpm)
        ) else (
            echo [X] No package manager found (npm, yarn, or pnpm required)
            pause
            exit /b 1
        )
    )
)

echo.

REM Test credentials
echo Testing credentials...

(
    echo import { CloudinaryAssetMgmt } from "@cloudinary/asset-management";
    echo import * as fs from "fs";
    echo import * as path from "path";
    echo.
    echo const envPath = path.join(process.cwd(), ".env");
    echo if (fs.existsSync(envPath^)) {
    echo   const envContent = fs.readFileSync(envPath, "utf-8");
    echo   envContent.split("\n").forEach((line) => {
    echo     const [key, ...values] = line.split("=");
    echo     if (key && values.length > 0^) {
    echo       process.env[key.trim()] = values.join("=").trim();
    echo     }
    echo   });
    echo }
    echo.
    echo const client = new CloudinaryAssetMgmt({
    echo   cloudName: process.env.CLOUDINARY_CLOUD_NAME,
    echo   security: {
    echo     cloudinaryAuth: {
    echo       apiKey: process.env.CLOUDINARY_API_KEY,
    echo       apiSecret: process.env.CLOUDINARY_API_SECRET,
    echo     },
    echo   },
    echo });
    echo.
    echo try {
    echo   const usage = await client.usage.getUsage();
    echo   console.log("√ Credentials verified!");
    echo   console.log(`Account: ${usage.objects ^| ^| 0} objects`);
    echo   console.log(`Storage: ${Math.round((usage.bytes ^| ^| 0) / 1024 / 1024)}MB`);
    echo   process.exit(0);
    echo } catch (error^) {
    echo   console.error("X Credentials failed:", error.message);
    echo   process.exit(1);
    echo }
) > test-credentials.mjs

call node test-credentials.mjs
set TEST_RESULT=%errorlevel%

del test-credentials.mjs

if %TEST_RESULT% equ 0 (
    echo [√] Credentials verified!
) else (
    echo [X] Credential test failed
    pause
    exit /b 1
)

echo.

REM Configure MCP
echo Configuring MCP Server (for Claude, Cursor, etc.)...
echo.
set /p IDE_CHOICE="Which IDE are you using? (claude/cursor/other): "

if /i "%IDE_CHOICE%"=="claude" (
    echo.
    echo Add this to %%APPDATA%%\Claude\claude_desktop_config.json:
    echo.
    echo {
    echo   "mcpServers": {
    echo     "cloudinary-asset-mgmt": {
    echo       "command": "npx",
    echo       "args": [
    echo         "-y",
    echo         "--package", "@cloudinary/asset-management",
    echo         "--",
    echo         "mcp", "start",
    echo         "--api-key", "%API_KEY%",
    echo         "--api-secret", "%API_SECRET%",
    echo         "--cloud-name", "%CLOUD_NAME%"
    echo       ]
    echo     }
    echo   }
    echo }
    echo.
    echo [!] After updating config, restart Claude Desktop
) else if /i "%IDE_CHOICE%"=="cursor" (
    echo.
    echo Create .cursor\mcp.json with:
    echo.
    echo {
    echo   "mcpServers": {
    echo     "cloudinary-asset-mgmt": {
    echo       "command": "npx",
    echo       "args": [
    echo         "-y",
    echo         "--package", "@cloudinary/asset-management",
    echo         "--",
    echo         "mcp", "start",
    echo         "--api-key", "%API_KEY%",
    echo         "--api-secret", "%API_SECRET%",
    echo         "--cloud-name", "%CLOUD_NAME%"
    echo       ]
    echo     }
    echo   }
    echo }
    echo.
    echo [!] After creating config, restart Cursor
) else (
    echo See BLACKBOX_AI_INTEGRATION.md for detailed MCP setup instructions
)

echo.

REM Summary
echo.
echo ==================================================================
echo √ Setup Complete!
echo ==================================================================
echo.
echo Documents created:
echo   + BLACKBOX_AI_SKILL.md - Complete API reference
echo   + BLACKBOX_AI_INTEGRATION.md - Integration guide
echo   + blackbox-skill.yaml - Skill manifest
echo   + .env - Your Cloudinary credentials (secured)
echo.
echo Next steps:
echo   1. Read BLACKBOX_AI_INTEGRATION.md for detailed instructions
echo   2. Configure your IDE (Claude/Cursor) if using MCP
echo   3. Check BLACKBOX_AI_SKILL.md for operation examples
echo   4. Start using Cloudinary in BLACKBOX AI!
echo.
echo Resources:
echo   + https://cloudinary.com/console
echo   + https://cloudinary.com/documentation
echo   + https://github.com/cloudinary/asset-management-js
echo.

pause
