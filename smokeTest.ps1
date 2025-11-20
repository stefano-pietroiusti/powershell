Start-Transcript -Path "C:\Logs\SmokeTest.log"

Write-Output "Smoke test running under: $($env:USERNAME)"
Write-Output "PowerShell edition: $($PSVersionTable.PSEdition)"
Write-Output "PowerShell version: $($PSVersionTable.PSVersion)"

# Simple file write
"Hello from $env:USERNAME at $(Get-Date)" | Out-File "C:\Logs\SmokeTestOutput.txt"

Stop-Transcript
