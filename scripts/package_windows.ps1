$ErrorActionPreference = "Stop"
$APP_NAME = "NovaClash"
$VERSION  = "0.1.0"
$DIST     = "dist"
$SRC      = "build\windows\x64\runner\Release"
New-Item -ItemType Directory -Force -Path $DIST | Out-Null

# 1) zip 便携包
Compress-Archive -Path "$SRC\*" -DestinationPath "$DIST\${APP_NAME}-${VERSION}-windows-x64.zip" -Force

# 2) NSIS 安装包
choco install nsis -y --no-progress | Out-Null
$exe = Get-ChildItem "$SRC\*.exe" | Select-Object -First 1
makensis /DAPP_NAME="$APP_NAME" /DVERSION="$VERSION" /DSRC_DIR="$SRC" /DAPP_EXE="$($exe.Name)" /DOUT_FILE="$DIST\${APP_NAME}-${VERSION}-windows-x64-setup.exe" scripts\installer.nsi

Get-ChildItem $DIST | ForEach-Object { Write-Host $_.Name }
