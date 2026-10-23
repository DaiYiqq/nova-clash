; NovaClash Windows NSIS 安装脚本
Unicode true

!ifndef APP_NAME
  !define APP_NAME "NovaClash"
!endif
!ifndef VERSION
  !define VERSION "0.1.9"
!endif
!ifndef SRC_DIR
  !define SRC_DIR "build\windows\x64\runner\Release"
!endif
!ifndef APP_EXE
  !define APP_EXE "nova_clash.exe"
!endif
!ifndef OUT_FILE
  !define OUT_FILE "dist\NovaClash-setup.exe"
!endif
!ifndef ICON_PATH
  !define ICON_PATH "..\assets\icon\icon.ico"
!endif

Name "${APP_NAME}"
OutFile "${OUT_FILE}"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin
SetCompressor /SOLID lzma
BrandingText "NovaClash 安装程序 · DaiYi"
UninstallText "即将从你的电脑中卸载 ${APP_NAME}，点击「卸载」继续。"

Icon "${ICON_PATH}"
UninstallIcon "${ICON_PATH}"

Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Section "NovaClash" SecMain
  SetOutPath "$INSTDIR"
  File /r "${SRC_DIR}\*"
  WriteUninstaller "$INSTDIR\uninstall.exe"
  CreateShortCut "$SMPROGRAMS\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
  CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
  WriteRegStr HKLM "Software\${APP_NAME}" "InstallDir" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "DaiYi"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayIcon" "$INSTDIR\${APP_EXE}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "$SMPROGRAMS\${APP_NAME}.lnk"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKLM "Software\${APP_NAME}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
SectionEnd
