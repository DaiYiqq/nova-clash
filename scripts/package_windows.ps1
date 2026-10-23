$ErrorActionPreference = "Stop"
$APP_NAME = "NovaClash"
$VERSION  = "0.1.9"
$DIST     = "dist"
$SRC      = "build\windows\x64\runner\Release"
New-Item -ItemType Directory -Force -Path $DIST | Out-Null

# 1) zip 便携包（始终产出）
Compress-Archive -Path "$SRC\*" -DestinationPath "$DIST\${APP_NAME}-${VERSION}-windows-x64.zip" -Force
Write-Host "zip 便携包已生成"

# 2) 定位 makensis
function Find-Makensis {
  $cands = @(
    "C:\Program Files (x86)\NSIS\makensis.exe",
    "C:\Program Files\NSIS\makensis.exe"
  )
  foreach ($c in $cands) { if (Test-Path $c) { return $c } }
  $cmd = Get-Command makensis -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  return $null
}

$mk = Find-Makensis
if (-not $mk) {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + $env:Path
  $mk = Find-Makensis
}
$attempt = 0
while (-not $mk -and $attempt -lt 3) {
  $attempt++
  Write-Host "尝试 choco 安装 NSIS（第 $attempt 次）..."
  try { choco install nsis -y --no-progress 2>&1 | Out-Null } catch {}
  Start-Sleep -Seconds 3
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + $env:Path
  $mk = Find-Makensis
}

# 3) 生成 NSIS 安装程序（尽力而为）
try {
  if (-not $mk) {
    Write-Host "尝试直接下载 NSIS 静默安装..."
    $url = "https://sourceforge.net/projects/nsis/files/NSIS%203/3.11/nsis-3.11-setup.exe/download"
    $setup = Join-Path $env:TEMP "nsis-setup.exe"
    try {
      Invoke-WebRequest -Uri $url -OutFile $setup -UseBasicParsing -TimeoutSec 150
      Start-Process -FilePath $setup -ArgumentList "/S" -Wait
      Start-Sleep -Seconds 4
      $mk = Find-Makensis
    } catch { Write-Host ("NSIS 下载/安装失败：" + $_.Exception.Message) }
  }
  if ($mk) {
    $srcAbs = (Resolve-Path $SRC).Path
    $distAbs = (Resolve-Path $DIST).Path
    $exe = Get-ChildItem "$SRC\*.exe" | Select-Object -First 1
    $out = Join-Path $distAbs ($APP_NAME + "-" + $VERSION + "-windows-x64-setup.exe")
    $argList = @(
      ('/DAPP_NAME={0}' -f $APP_NAME)
      ('/DVERSION={0}' -f $VERSION)
      ('/DSRC_DIR={0}' -f $srcAbs)
      ('/DAPP_EXE={0}' -f $exe.Name)
      ('/DOUT_FILE={0}' -f $out)
    )
    $ico = "assets\icon\icon.ico"
    if (Test-Path $ico) { $argList += ('/DICON_PATH={0}' -f (Resolve-Path $ico).Path) }
    $argList += "scripts\installer.nsi"
    & $mk @argList
    if ((Test-Path $out) -and ($LASTEXITCODE -eq 0)) {
      Write-Host "NSIS 安装程序已生成: $out"
    } else {
      Write-Host "NSIS 打包失败（退出码 $LASTEXITCODE），仅保留 zip"
    }
  } else {
    Write-Host "未找到 makensis，跳过 NSIS（仅 zip）"
  }
} catch {
  Write-Host ("NSIS 异常，跳过（仅 zip）：" + $_.Exception.Message)
}
$global:LASTEXITCODE = 0

Write-Host "--- dist/ ---"
Get-ChildItem $DIST | ForEach-Object { Write-Host $_.Name }
exit 0
