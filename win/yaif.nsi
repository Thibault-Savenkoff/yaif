; YAIF for Windows installer (NSIS 3): yaif.exe on the PATH, WIC codec registered (Explorer thumbnails,
; Photos), uninstaller in Settings > Apps. Built by win/dist.sh from dist/yaif-windows/.
; Per-user (no admin) or per-machine (admin) install, picked on a wizard page: MultiUser.nsh
; handles the privilege check, the registry hive (ShCtx) and $InstDir for both modes.
Unicode true
!include x64.nsh
!include WinMessages.nsh
!include StrFunc.nsh
!include FileFunc.nsh
!insertmacro GetSize
${UnStrRep}

!define UNINST "Software\Microsoft\Windows\CurrentVersion\Uninstall\YAIF"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY "${UNINST}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME "InstallMode"
!define MULTIUSER_INSTALLMODE_INSTDIR "YAIF"
; Highest: an administrator account gets the UAC prompt at launch, even for "only for me". NSIS's MultiUser
; refuses the all-users / current-user page with Standard ("mixed mode needs Admin, Power or Highest"), and
; ALLOW_ELEVATION only helps without that page. A standard account gets no prompt. install.ps1 never asks.
!define MULTIUSER_EXECUTIONLEVEL Highest
; The installer is 32-bit, so MultiUser.nsh would pick $PROGRAMFILES, i.e. "Program Files (x86)",
; for a 64-bit yaif.exe. The MSI already installs to ProgramFiles64Folder.
!define MULTIUSER_USE_PROGRAMFILES64
!define MULTIUSER_MUI

!include LogicLib.nsh
!include MultiUser.nsh
!include MUI2.nsh

; win/dist.sh passes yaif.li's version (makensis -DVERSION=...), so this cannot drift from it.
!ifndef VERSION
  !define VERSION "dev"
!endif

Name "YAIF"
OutFile "..\dist\yaif-setup.exe"
SetCompressor /SOLID lzma
Icon "yaif.ico"
UninstallIcon "yaif.ico"
ManifestDPIAware true

!define ENV_ALLUSERS "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
!define ENV_CURRENTUSER "Environment"

; What the install changes on the system, said before it happens (SignPath Foundation's terms ask
; for it; it is also the honest thing). Keep in step with the sections below and with README.md.
!define MUI_WELCOMEPAGE_TEXT "$(WELCOME)"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_LICENSE "..\LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; English first: it is the fallback when Windows is in neither language. NSIS picks the installer's
; language from the Windows display language, so there is no language dialog.
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "PortugueseBR"
!insertmacro MUI_LANGUAGE "Portuguese"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Turkish"
!insertmacro MUI_LANGUAGE "Japanese"
!insertmacro MUI_LANGUAGE "Korean"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "Arabic"
!insertmacro MUI_LANGUAGE "Hindi"
!insertmacro MUI_LANGUAGE "Indonesian"
!insertmacro MUI_LANGUAGE "Vietnamese"
!insertmacro MUI_LANGUAGE "Ukrainian"
!include lang.nsh

Function .onInit
  ${IfNot} ${RunningX64}
    MessageBox MB_OK|MB_ICONSTOP "$(NEED64)"
    Abort
  ${EndIf}
  !insertmacro MULTIUSER_INIT
  SetRegView 64
FunctionEnd

Function un.onInit
  !insertmacro MULTIUSER_UNINIT
  SetRegView 64
FunctionEnd

; Active Setup runs a command once per user, in that user's own session, the next time they log
; on. It is the only way a per-machine install can reach a real user's PowerShell profile: a
; process elevated to install writes the profile of the account that elevated, and an MSI custom
; action writes SYSTEM's.
!define ACTIVESETUP "SOFTWARE\Microsoft\Active Setup\Installed Components\{C041617A-3C51-4727-8351-E0BDF68C733B}"

; YAIF was called NOVA up to 2.0.0-beta.6: run that install's own uninstaller first, silently, for
; this computer and this account. _?= keeps it in place so ExecWait really waits for it.
!macro RemoveNova ROOT
  ReadRegStr $R0 ${ROOT} "Software\Microsoft\Windows\CurrentVersion\Uninstall\NOVA" "InstallLocation"
  ${If} $R0 != ""
  ${AndIf} ${FileExists} "$R0\uninstall.exe"
    DetailPrint "$(REMOVING_NOVA)"
    ExecWait '"$R0\uninstall.exe" /S _?=$R0'
    Delete "$R0\uninstall.exe"
    RMDir "$R0"
  ${EndIf}
!macroend

Section "-RemoveNova"
  !insertmacro RemoveNova HKLM
  !insertmacro RemoveNova HKCU
SectionEnd

Section "YAIF" SecCore
  SectionIn RO
  SetOutPath "$InstDir"
  File "..\dist\yaif-windows\yaif.exe"
  ; Every DLL win/dist.sh staged: the codec, zlib/libwebp, and LibRaw with its own dependencies.
  ; A glob so that adding one to dist.sh does not silently leave it out of the installer.
  File "..\dist\yaif-windows\*.dll"
  ; The two PowerShell scripts live in scripts\, not next to yaif.exe: $InstDir is on the PATH, where PowerShell
  ; would offer them as commands when completing `yaif`. Earlier betas put them next to it: tidy those up.
  Delete "$InstDir\yaif-completion.ps1"
  Delete "$InstDir\yaif-profile.ps1"
  SetOutPath "$InstDir\scripts"
  File "..\dist\yaif-windows\scripts\yaif-profile.ps1"
  File "..\dist\yaif-windows\scripts\yaif-completion.ps1"
  SetOutPath "$InstDir"
  File "..\dist\yaif-windows\LICENSE-*.txt"
  File "..\dist\yaif-windows\README.txt"
  SetOutPath "$InstDir\samples"
  File "..\dist\yaif-windows\*.yaif"
  WriteUninstaller "$InstDir\uninstall.exe"

  ; the installer is 32-bit: run the 64-bit regsvr32 for the 64-bit codec
  ${DisableX64FSRedirection}
  ${if} $MultiUser.InstallMode == "AllUsers"
    ExecWait '"$SYSDIR\regsvr32.exe" /s "$InstDir\yaif_wic.dll"' $0
  ${else}
    ; this user only: HKCU\Software\Classes, no administrator rights needed (DllInstall in yaif_wic.cpp)
    ExecWait '"$SYSDIR\regsvr32.exe" /s /n /i:user "$InstDir\yaif_wic.dll"' $0
  ${endif}
  ${EnableX64FSRedirection}
  StrCmp $0 0 +2
    MessageBox MB_OK|MB_ICONEXCLAMATION "$(REGSVR)"

  ; yaif.exe on the PATH (new terminals): HKLM for an all-users install, HKCU for the current user only
  ; ReadRegStr on a value longer than ${NSIS_MAX_STRLEN} comes back EMPTY with the error flag set, the same
  ; as for a missing value: writing "$1;dir" then would replace the whole PATH. Tell the two apart.
  ClearErrors
  ${if} $MultiUser.InstallMode == "AllUsers"
    ReadRegStr $1 HKLM "${ENV_ALLUSERS}" "Path"
  ${else}
    ReadRegStr $1 HKCU "${ENV_CURRENTUSER}" "Path"
  ${endif}
  IfErrors 0 pathread
    StrCpy $4 0
    pathenum:
      ${if} $MultiUser.InstallMode == "AllUsers"
        EnumRegValue $2 HKLM "${ENV_ALLUSERS}" $4
      ${else}
        EnumRegValue $2 HKCU "${ENV_CURRENTUSER}" $4
      ${endif}
      StrCmp $2 "" pathnone
      StrCmp $2 "Path" pathlong
      IntOp $4 $4 + 1
      Goto pathenum
    pathnone:
    ; no PATH value at all: create it
    ${if} $MultiUser.InstallMode == "AllUsers"
      WriteRegExpandStr HKLM "${ENV_ALLUSERS}" "Path" "$InstDir"
    ${else}
      WriteRegExpandStr HKCU "${ENV_CURRENTUSER}" "Path" "$InstDir"
    ${endif}
    Goto pathdone
  pathread:
  StrLen $3 "$1;$InstDir"
  IntCmp $3 ${NSIS_MAX_STRLEN} pathlong 0 pathlong
  Push $1
  Push ";$InstDir"
  Call StrContains
  Pop $2
  StrCmp $2 "" 0 pathdone
    ${if} $MultiUser.InstallMode == "AllUsers"
      WriteRegExpandStr HKLM "${ENV_ALLUSERS}" "Path" "$1;$InstDir"
    ${else}
      WriteRegExpandStr HKCU "${ENV_CURRENTUSER}" "Path" "$1;$InstDir"
    ${endif}
    Goto pathdone
  pathlong:
    MessageBox MB_OK "$(PATH_LONG)"
  pathdone:
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment" /TIMEOUT=2000

  WriteRegStr ShCtx "${UNINST}" "DisplayName" "YAIF image format"
  WriteRegStr ShCtx "${UNINST}" "DisplayVersion" "${VERSION}"
  WriteRegStr ShCtx "${UNINST}" "Publisher" "Thibault SAVENKOFF"
  WriteRegStr ShCtx "${UNINST}" "InstallLocation" "$InstDir"
  WriteRegStr ShCtx "${UNINST}" "DisplayIcon" "$InstDir\yaif.exe,0"
  WriteRegStr ShCtx "${UNINST}" "UninstallString" '"$InstDir\uninstall.exe"'
  ; size shown in Settings > Apps (KB)
  ${GetSize} "$InstDir" "/S=0K" $0 $1 $2
  WriteRegDWORD ShCtx "${UNINST}" "EstimatedSize" "$0"
  WriteRegDWORD ShCtx "${UNINST}" "NoModify" 1
  WriteRegDWORD ShCtx "${UNINST}" "NoRepair" 1
  WriteRegStr ShCtx "${UNINST}" "InstallMode" "$MultiUser.InstallMode"
SectionEnd

; PowerShell has no auto-load directory for argument completers, so the completion only works once
; a line loads it from the user's profile. PowerShell edits its own file (yaif-profile.ps1) rather
; than NSIS guessing its encoding; the script is idempotent, so running it twice changes nothing.
Section -Completion
  ; Now, for whoever is installing: UAC elevates the same account on a personal machine, so the
  ; profile written is the right one. Active Setup then covers the case that breaks -- another
  ; account's credentials at the UAC prompt -- and every other user of a per-machine install.
  ExecWait '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "$InstDir\scripts\yaif-profile.ps1" -Script "$InstDir\scripts\yaif-completion.ps1"'
  ${if} $MultiUser.InstallMode == "AllUsers"
    WriteRegStr HKLM "${ACTIVESETUP}" "" "YAIF tab completion"
    WriteRegStr HKLM "${ACTIVESETUP}" "Version" "1"
    WriteRegStr HKLM "${ACTIVESETUP}" "StubPath" '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "$InstDir\scripts\yaif-profile.ps1" -Script "$InstDir\scripts\yaif-completion.ps1"'
  ${endif}
SectionEnd

; Pushes "" if the needle (top) is not in the haystack (below it), else the needle.
Function StrContains
  Exch $R0   ; needle
  Exch
  Exch $R1   ; haystack
  Push $R2
  Push $R3
  Push $R4
  StrLen $R2 $R0
  StrCpy $R4 0
  loop:
    StrCpy $R3 $R1 $R2 $R4
    StrCmp $R3 $R0 found
    StrCmp $R3 "" notfound
    IntOp $R4 $R4 + 1
    Goto loop
  notfound:
    StrCpy $R0 ""
  found:
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

Section "Uninstall"
  ${DisableX64FSRedirection}
  ${if} $MultiUser.InstallMode == "AllUsers"
    ExecWait '"$SYSDIR\regsvr32.exe" /s /u "$InstDir\yaif_wic.dll"'
  ${else}
    ExecWait '"$SYSDIR\regsvr32.exe" /s /u /n /i:user "$InstDir\yaif_wic.dll"'
  ${endif}
  ${EnableX64FSRedirection}
  ClearErrors
  ${if} $MultiUser.InstallMode == "AllUsers"
    ReadRegStr $1 HKLM "${ENV_ALLUSERS}" "Path"
  ${else}
    ReadRegStr $1 HKCU "${ENV_CURRENTUSER}" "Path"
  ${endif}
  ; empty + error flag: missing (nothing to remove) or too long to read (leave it alone)
  IfErrors unpathdone
  StrLen $3 $1
  IntCmp $3 ${NSIS_MAX_STRLEN} unpathdone 0 unpathdone
  ${UnStrRep} $1 $1 ";$InstDir" ""
  ${if} $MultiUser.InstallMode == "AllUsers"
    WriteRegExpandStr HKLM "${ENV_ALLUSERS}" "Path" $1
  ${else}
    WriteRegExpandStr HKCU "${ENV_CURRENTUSER}" "Path" $1
  ${endif}
  unpathdone:
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0 "STR:Environment" /TIMEOUT=2000
  DeleteRegKey ShCtx "${UNINST}"
  DeleteRegKey HKLM "${ACTIVESETUP}"
  ; Only this user's profile: Active Setup has no undo, so a line it added for another account
  ; stays until that user runs yaif-profile.ps1 -Remove. It loads nothing once the file is gone.
  ; nsExec + -Command, not ExecWait + -File: the latter left the profile line behind on a real PC
  ; (the same command run by hand worked), this form removed it from both PowerShell profiles.
  nsExec::Exec '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "& \"$InstDir\scripts\yaif-profile.ps1\" -Remove"'
  Pop $0
  RMDir /r "$InstDir\samples"
  Delete "$InstDir\*.exe"
  Delete /REBOOTOK "$InstDir\*.dll"   ; Explorer may still hold the codec
  Delete "$InstDir\LICENSE-*.txt"
  Delete "$InstDir\README.txt"
  Delete "$InstDir\scripts\yaif-completion.ps1"
  Delete "$InstDir\scripts\yaif-profile.ps1"
  RMDir "$InstDir\scripts"
  Delete "$InstDir\yaif-completion.ps1"
  Delete "$InstDir\yaif-profile.ps1"
  RMDir "$InstDir"
SectionEnd
