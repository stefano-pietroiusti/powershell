Start-Transcript -Path "D:\Logs\CredUnifiedTest.log"

Write-Output "=== Smoke Test ==="
Write-Output "Running under user: $($env:USERNAME)"
Write-Output "PowerShell edition: $($PSVersionTable.PSEdition)"
Write-Output "PowerShell version: $($PSVersionTable.PSVersion)"
"Hello from $env:USERNAME at $(Get-Date)" | Out-File "D:\Logs\SmokeTestOutput.txt"

# Target credential details
$target   = "UnifiedApp"
$username = "UnifiedUser"
$password = "Un1fiedP@ss!"

Write-Output "`n=== Credential Manager Test ==="

# Detect engine and module availability
if ($PSVersionTable.PSEdition -eq "Core") {
    Write-Output "Running under PowerShell Core (pwsh). Using cmdkey fallback."
    $useCmdKey = $true
} else {
    Write-Output "Running under Windows PowerShell."
    try {
        Import-Module CredentialManager -ErrorAction Stop
        $useCmdKey = $false
    } catch {
        Write-Output "CredentialManager module not available, falling back to cmdkey."
        $useCmdKey = $true
    }
}

# Add + Read credential
if (-not $useCmdKey) {
    Write-Output "Using CredentialManager module..."
    New-StoredCredential -Target $target -UserName $username -Password $password -Persist LocalMachine
    $cred = Get-StoredCredential -Target $target
    if ($cred) {
        Write-Output "Credential retrieved via CredentialManager: $($cred.UserName)"
    } else {
        Write-Output "Credential not found via CredentialManager."
    }
} else {
    Write-Output "Using cmdkey..."
    cmdkey /add:$target /user:$username /pass:$password
    $cred = cmdkey /list | Select-String $target
    if ($cred) {
        Write-Output "Credential for $target successfully stored via cmdkey."
    } else {
        Write-Output "Credential for $target not found via cmdkey."
    }
}

Write-Output "`n=== Test Complete ==="
Stop-Transcript
