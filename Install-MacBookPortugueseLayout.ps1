# Adds the standard Portuguese (Portugal) layout and installs the small
# AutoHotkey v2 helper that restores Mac-specific Portuguese key mappings.
[CmdletBinding()]
param(
    [switch] $AddOnly
)

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -ge 6 -and -not $IsWindows) {
    throw 'Run this script inside Windows PowerShell on the Windows VM.'
}

$languageTag = 'pt-PT'
$inputMethodTip = '0816:00000816'
$helperName = 'MacBookPortugueseDeadKeys.ahk'
$helperSource = Join-Path $PSScriptRoot $helperName

if (-not (Test-Path -LiteralPath $helperSource)) {
    throw "The helper file '$helperName' must be in the same folder as this script."
}

$ahkCandidates = @(
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe",
    "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe",
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey.exe"
)
$ahkExe = $ahkCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $ahkExe) {
    throw 'AutoHotkey v2 is required. Install it from https://www.autohotkey.com/ and run this script again.'
}

try {
    # Keep the cmdlet's typed List<WinUserLanguage>; Set-WinUserLanguageList
    # rejects a plain PowerShell object array on some Windows versions.
    $languages = Get-WinUserLanguageList
} catch {
    throw "Could not read the Windows user language list: $($_.Exception.Message)"
}

$portuguese = $languages | Where-Object LanguageTag -eq $languageTag | Select-Object -First 1
$languageListChanged = $false
if (-not $portuguese) {
    $newLanguage = New-WinUserLanguageList -Language $languageTag
    $newLanguage[0].InputMethodTips.Clear()
    $newLanguage[0].InputMethodTips.Add($inputMethodTip)
    $languages.Add($newLanguage[0])
    $languageListChanged = $true
} elseif (-not $portuguese.InputMethodTips.Contains($inputMethodTip)) {
    $portuguese.InputMethodTips.Add($inputMethodTip)
    $languageListChanged = $true
}

if ($languageListChanged) {
    Set-WinUserLanguageList -LanguageList $languages -Force
}
if (-not $AddOnly) {
    Set-WinDefaultInputMethodOverride -InputTip $inputMethodTip
}

$installDirectory = Join-Path $env:LOCALAPPDATA 'MacBookPortugueseLayout'
New-Item -ItemType Directory -Path $installDirectory -Force | Out-Null
$installedHelper = Join-Path $installDirectory $helperName
Copy-Item -LiteralPath $helperSource -Destination $installedHelper -Force

$startupDirectory = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDirectory 'MacBook Portuguese Dead Keys.lnk'
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $ahkExe
$shortcut.Arguments = '"' + $installedHelper + '"'
$shortcut.WorkingDirectory = $installDirectory
$shortcut.Description = 'MacBook Portuguese dead tilde and circumflex keys'
$shortcut.Save()

Get-Process -Name 'AutoHotkey*' -ErrorAction SilentlyContinue | Where-Object {
    $_.Path -and (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine -like "*$helperName*"
} | Stop-Process -Force
Start-Process -FilePath $ahkExe -ArgumentList ('"' + $installedHelper + '"')

Write-Host 'Portuguese (Portugal) is installed and selected.' -ForegroundColor Green
Write-Host 'The MacBook Portuguese key-mapping helper is running and will start at sign-in.'
Write-Host 'The key immediately to the right of Ç now acts as dead tilde; Shift+that key starts circumflex.'
