$ErrorActionPreference = "Stop"
$APP_NAME = "NovaClash"
$VERSION  = "0.1.0"
$DIST     = "dist"
$SRC      = "build\windows\x64\runner\Release"
New-Item -ItemType Directory -Force -Path $DIST | Out-Null

# 1) zip 便携包（始终产出）
Compress-Archive -Path "$SRC\*" -DestinationPath "$DIST\${APP_NAME}-${VERSION}-windows-x64.zip" -Force
Write-Host "zip 便携包已生成"

# 2) NSIS 安装程序（尽力而为）
try {
  $srcAbs = (Resolve-Path $SRC).Path
  $mk = "C:\Program Files (x86)\NSIS\makensis.exe"
  if (-not (Test-Path $mk)) { $cmd = Get-Command makensis -ErrorAction SilentlyContinue; if ($cmd) { $mk = $cmd.Source } }
  if ($mk -and (Test-Path $mk)) {
    $exe = Get-ChildItem "$SRC\*.exe" | Select-Object -First 1
    & $mk /DAPP_NAME="$APP_NAME" /DVERSION="$VERSION" /DSRC_DIR="$srcAbs" /DAPP_EXE="$($exe.Name)" /DOUT_FILE="$DIST\${APP_NAME}-${VERSION}-windows-x64-setup.exe" scripts\installer.nsi
    if ($LASTEXITCODE -eq 0) { Write-Host "NSIS 安装程序已生成" } else { Write-Host "NSIS 失败(退出码 $LASTEXITCODE)，仅保留 zip" }
  } else {
    Write-Host "未找到 makensis，跳过 NSIS（仅 zip）"
  }
} catch {
  Write-Host "NSIS 异常，跳过（仅 zip）：$($_.Exception.Message)"
}
$global:LASTEXITCODE = 0

Write-Host "--- dist/ ---"
Get-ChildItem $DIST | ForEach-Object { Write-Host $_.Name }
exit 0
