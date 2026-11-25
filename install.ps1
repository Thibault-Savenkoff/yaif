# YAIF installer for Windows, per user (no administrator needed):
#   irm https://raw.githubusercontent.com/Thibault-Savenkoff/yaif/v2/install.ps1 | iex
# Downloads the latest v2 release's .zip, checks its SHA-256, unpacks it to
# %LOCALAPPDATA%\Programs\YAIF, puts that folder on your PATH, adds the Tab-completion line to your
# PowerShell profile and an entry in Settings > Apps. Uninstall from there. It does NOT register the
# Explorer thumbnail codec (that needs administrator): use the -setup.exe for it.
# A script run this way is not SmartScreen- or Defender-checked like a downloaded .exe.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # Windows PowerShell 5.1 downloads 10x slower with the bar
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$repo = 'Thibault-Savenkoff/yaif'
# Test-only overrides, like install.sh's
$feed = if ($env:YAIF_FEED) { $env:YAIF_FEED } else { "https://github.com/$repo/releases.atom" }
$base = if ($env:YAIF_RELEASE_BASE) { $env:YAIF_RELEASE_BASE } else { "https://github.com/$repo/releases/download" }
$dir = Join-Path $env:LOCALAPPDATA 'Programs\YAIF'
$unkey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\YAIF'

if (-not [Environment]::Is64BitOperatingSystem) { throw 'YAIF needs 64-bit Windows.' }
# An install made by the setup (or the MSI) owns that Settings > Apps entry: do not overwrite it.
foreach ($k in $unkey, 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\YAIF') {
    $loc = (Get-ItemProperty $k -ErrorAction SilentlyContinue).InstallLocation
    if ($loc -and $loc -ne $dir) { throw "YAIF is already installed in ${loc}: uninstall it first (Settings > Apps)." }
}

# Latest v2 release (the Atom feed, not the API: 60 requests an hour per IP without a token).
$tag = [regex]::Match((Invoke-WebRequest $feed -UseBasicParsing).Content, 'releases/tag/(v2\.[^"<]+)').Groups[1].Value
if (-not $tag) { throw 'no v2 release found' }
$ver = $tag.Substring(1)
$zip = "yaif-$ver-windows-x86_64.zip"
Write-Host "Installing YAIF $ver"
$tmp = Join-Path ([IO.Path]::GetTempPath()) "yaif-$([guid]::NewGuid())"
New-Item -ItemType Directory $tmp | Out-Null
try {
    Invoke-WebRequest "$base/$tag/$zip" -OutFile "$tmp\$zip" -UseBasicParsing
    $sums = (Invoke-WebRequest "$base/$tag/SHA256SUMS" -UseBasicParsing).Content
    $want = [regex]::Match($sums, "(?m)^([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($zip))\s*$").Groups[1].Value
    if (-not $want) { throw "$zip is not in SHA256SUMS" }
    if ((Get-FileHash "$tmp\$zip" -Algorithm SHA256).Hash -ne $want) { throw "${zip}: checksum mismatch, nothing installed" }
    Expand-Archive "$tmp\$zip" "$tmp\x"
    # yaif.exe or a DLL in use (a terminal still running yaif, Explorer holding a codec) fails here:
    # Stop = nothing half-copied is reported as done.
    New-Item -ItemType Directory $dir -Force | Out-Null
    Remove-Item "$dir\yaif-completion.ps1", "$dir\yaif-profile.ps1" -ErrorAction SilentlyContinue   # where the betas before 13 put them
    Copy-Item "$tmp\x\yaif-windows\*" $dir -Recurse -Force
} finally { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }

# PATH (user): edit the registry value itself, [Environment]::SetEnvironmentVariable would flatten
# a REG_EXPAND_SZ Path into a REG_SZ and break its %VARS%.
$env_ = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
$path = $env_.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
if (";$path;".ToLower().IndexOf(";$($dir.ToLower());") -lt 0) {
    $env_.SetValue('Path', ($path.TrimEnd(';') + ";$dir").TrimStart(';'), 'ExpandString')
}
$env_.Close()
# Setting then deleting a user variable makes Windows broadcast "environment changed" (new terminals see the PATH).
[Environment]::SetEnvironmentVariable('YAIF_NOTIFY', '1', 'User'); [Environment]::SetEnvironmentVariable('YAIF_NOTIFY', $null, 'User')

# Tab completion: the profile script runs under this same host, with the policy bypassed (a
# default Windows PowerShell refuses unsigned scripts).
& (Get-Process -Id $PID).Path -NoProfile -ExecutionPolicy Bypass -File "$dir\scripts\yaif-profile.ps1" -Script "$dir\scripts\yaif-completion.ps1"

# Uninstaller, kept next to yaif.exe so that Settings > Apps works offline.
@'
$dir = $PSScriptRoot
$ps = (Get-Process -Id $PID).Path
& $ps -NoProfile -ExecutionPolicy Bypass -File "$dir\scripts\yaif-profile.ps1" -Remove
$e = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
$p = $e.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
$e.SetValue('Path', (($p -split ';' | Where-Object { $_ -and $_ -ne $dir }) -join ';'), 'ExpandString')
$e.Close()
[Environment]::SetEnvironmentVariable('YAIF_NOTIFY', '1', 'User'); [Environment]::SetEnvironmentVariable('YAIF_NOTIFY', $null, 'User')
Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\YAIF' -Recurse -ErrorAction SilentlyContinue
# This script lives in $dir: let cmd delete the folder once we have exited.
Start-Process cmd -ArgumentList '/c', "ping -n 3 127.0.0.1 >nul & rmdir /s /q `"$dir`"" -WindowStyle Hidden
'@ | Set-Content "$dir\uninstall.ps1" -Encoding UTF8

New-Item $unkey -Force | Out-Null
$p = @{
    DisplayName = 'YAIF image format'; DisplayVersion = $ver; Publisher = 'Thibault SAVENKOFF'
    InstallLocation = $dir; DisplayIcon = "$dir\yaif.exe,0"
    UninstallString = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$dir\uninstall.ps1`""
}
foreach ($n in $p.Keys) { Set-ItemProperty $unkey $n $p[$n] }
$kb = [int]((Get-ChildItem $dir -Recurse -File | Measure-Object Length -Sum).Sum / 1KB)
New-ItemProperty $unkey EstimatedSize -Value $kb -PropertyType DWord -Force | Out-Null
New-ItemProperty $unkey NoModify -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "YAIF $ver installed in $dir. Open a new terminal and run: yaif --version"
Write-Host 'Uninstall: Settings > Apps > YAIF. Explorer thumbnails need the -setup.exe (administrator).'
