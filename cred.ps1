# Detect engine
if ($PSVersionTable.PSEdition -eq "Core") {
    Write-Output "Running under PowerShell Core (pwsh)."
    # CredentialManager module may not be available
    # Use cmdkey fallback
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

# Example usage
$target = "TestApp"
$username = "TestUser"
$password = "P@ssw0rd!"

if (-not $useCmdKey) {
    New-StoredCredential -Target $target -UserName $username -Password $password -Persist LocalMachine
    $cred = Get-StoredCredential -Target $target
    Write-Output "Retrieved via CredentialManager: $($cred.UserName)"
} else {
    cmdkey /add:$target /user:$username /pass:$password
    $cred = cmdkey /list | Select-String $target
    Write-Output "Retrieved via cmdkey: $cred"
}
