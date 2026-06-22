$StartupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$ShortcutPath  = Join-Path $StartupFolder "Start Company Portal.lnk"

$Command = @'
Start-Sleep -Seconds 1
Start-Process "companyportal:"
Start-Sleep -Seconds 1
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Start Company Portal.lnk" -Force -ErrorAction SilentlyContinue
'@

$EncodedCommand = [Convert]::ToBase64String(
    [System.Text.Encoding]::Unicode.GetBytes($Command)
)

$TargetPath = "powershellw.exe"
$Arguments  = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -EncodedCommand $EncodedCommand"

New-Item -Path $StartupFolder -ItemType Directory -Force | Out-Null

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetPath
$Shortcut.Arguments = $Arguments
$Shortcut.WorkingDirectory = $env:USERPROFILE
$Shortcut.Description = "Start Company Portal once after first user login"
$Shortcut.Save()

Write-Host "Shortcut created: $ShortcutPath"
