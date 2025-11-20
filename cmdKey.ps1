Start-Transcript -Path "C:\Logs\CmdKeyTest.log"

$target = "SmokeApp"
$username = "SmokeUser"
$password = "Sm0keP@ss!"

# Add credential
cmdkey /add:$target /user:$username /pass:$password

# Verify credential exists
$creds = cmdkey /list | Select-String $target
if ($creds) {
    Write-Output "Credential for $target successfully stored."
} else {
    Write-Output "Credential for $target not found."
}

Stop-Transcript
