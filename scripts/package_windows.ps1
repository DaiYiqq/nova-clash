$ErrorActionPreference = "Stop"
$APP_NAME = "NovaClash"
$VERSION  = "0.1.0"
$DIST     = "dist"
$SRC      = "build\windows\x64\runner\Release"
New-Item -ItemType Directory -Force -Path $DIST | Out-Null

# 1) zip 便携包（始终产出）
Compress-Archive -Path "$SRC\*" -DestinationPath "$DIST\${APP_NAME}-${VERSION}-windows-x64.zip" -Force
Write-Host "zip 便携包已生成"

# 2) NSIS 安装程序（尽力而为：失败不影响 zip）
try {
  choco install nsis -y --no-progress | Out-Null
  $mkPath = "C:\Program Files (x86)\NSIS\makensis.exe"
  if (-not (Test-Path $mkPath)) {
    $cmd = Get-Command makensis -ErrorAction SilentlyContinue
    if ($cmd) { $mkPath = $cmd.Source }
  }
  if ($mkPath -and (Test-Path $mkPath)) {
    $exe = Get-ChildItem "$SRC\*.exe" | Select-Object -First 1
    & $mkPath /DAPP_NAME="$APP_NAME" /DVERSION="$VERSION" /DSRC_DIR="$SRC" /DAPP_EXE="$($exe.Name)" /DOUT_FILE="$DIST\${APP_NAME}-${VERSION}-windows-x64-setup.exe" scripts\installer.nsi
    Write-Host "NSIS 安装程序已生成"
  } else {
    Write-Host "未找到 makensis，跳过 NSIS（仅 zip 便携包）"
  }
} catch {
  Write-Host "NSIS 打包失败，已跳过（仅 zip 便携包）：$($_.Exception.Message)"
}

Write-Host "--- dist/ ---"
Get-ChildItem $DIST | ForEach-Object { Write-Host $_.Name }
