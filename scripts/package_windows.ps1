$ErrorActionPreference = "Stop"
$APP_NAME = "NovaClash"
$VERSION  = "0.1.0"
$DIST     = "dist"
$SRC      = "build\windows\x64\runner\Release"
New-Item -ItemType Directory -Force -Path $DIST | Out-Null

# 1) zip 便携包
Compress-Archive -Path "$SRC\*" -DestinationPath "$DIST\${APP_NAME}-${VERSION}-windows-x64.zip" -Force

# 2) NSIS 安装程序（可选：NSIS 不可用则仅产出 zip）
choco install nsis -y --no-progress | Out-Null
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + $env:Path
$mk = Get-Command makensis -ErrorAction SilentlyContinue
if (-not $mk -and (Test-Path "C:\Program Files (x86)\NSIS\makensis.exe")) { $mk = Get-Item "C:\Program Files (x86)\NSIS\makensis.exe" }
if ($mk) {
  $exe = Get-ChildItem "$SRC\*.exe" | Select-Object -First 1
  & $mk.Source /DAPP_NAME="$APP_NAME" /DVERSION="$VERSION" /DSRC_DIR="$SRC" /DAPP_EXE="$($exe.Name)" /DOUT_FILE="$DIST\${APP_NAME}-${VERSION}-windows-x64-setup.exe" scripts\installer.nsi
  Write-Host "NSIS installer generated"
} else {
  Write-Host "NSIS 不可用，跳过安装程序（仅 zip 便携包）"
}

Get-ChildItem $DIST | ForEach-Object { Write-Host $_.Name }
