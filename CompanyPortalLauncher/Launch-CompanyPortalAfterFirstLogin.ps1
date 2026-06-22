# ---------------------------------------------------------------------------
# Launch Company Portal After First Login
#
# Creates a shortcut in the current user's Startup folder.
# At the next user sign-in:
#   - Company Portal is launched
#   - The shortcut removes itself
#
# Useful for Autopilot and post-provisioning scenarios where Company Portal
# needs to be started once after the user's first desktop session.
# ---------------------------------------------------------------------------

# User Startup folder
$StartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# Shortcut location
$ShortcutPath = Join-Path $StartupFolder "Start Company Portal.lnk"

# Command executed by the shortcut
$Command = @'
# Give the desktop a moment to finish loading
Start-Sleep -Seconds 10

# Launch Company Portal
Start-Process "companyportal:"

# Wait briefly to ensure the application has started
Start-Sleep -Seconds 5

# Remove the shortcut so it only runs once
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Start Company Portal.lnk" -Force -ErrorAction SilentlyContinue
'@

# Encode the command to keep the shortcut compact
$EncodedCommand = [Convert]::ToBase64String(
    [System.Text.Encoding]::Unicode.GetBytes($Command)
)

# Use the built-in Windows PowerShell executable
$TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

# Run hidden and bypass execution policy restrictions
$Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand $EncodedCommand"

# Ensure the Startup folder exists
New-Item -Path $StartupFolder -ItemType Directory -Force | Out-Null

# Create the shortcut
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)

$Shortcut.TargetPath = $TargetPath
$Shortcut.Arguments = $Arguments
$Shortcut.WorkingDirectory = $env:USERPROFILE
$Shortcut.Description = "Launch Company Portal once after first sign-in"

# Save the shortcut
$Shortcut.Save()

Write-Host "Shortcut created: $ShortcutPath"
