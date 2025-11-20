# powershell

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Scripts\CredTest.ps1"
$action = New-ScheduledTaskAction -Execute "pwsh.exe" -Argument "-ExecutionPolicy Bypass -File C:\Scripts\CredTest.ps1"
1. Run SmokeTest.ps1 → confirms service account execution context.
2. Run CmdKeyTest.ps1 → validates Credential Manager access via cmdkey.
3. Run CredTest.ps1 with conditional logic → ensures compatibility across Windows PowerShell and pwsh Core.

---------------------

Scheduled Task Registration (Service Account)

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File D:\Scripts\CredUnifiedTest.ps1"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
$principal = New-ScheduledTaskPrincipal -UserId "DOMAIN\ServiceAccount" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "CredUnifiedTest" -Action $action -Trigger $trigger -Principal $principal
Start-ScheduledTask -TaskName "CredUnifiedTest"

Group Managed Service Accounts (gMSA) are special:

• They cannot log on interactively.
• They are designed for services and scheduled tasks.
• You reference them without a password (DOMAIN\MyGmsa$).


Here’s the gMSA variant:

Script (same as above, paths already on D:)

No changes needed inside the script — it will run under the gMSA context.

Task Registration for gMSA

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File D:\Scripts\CredUnifiedTest.ps1"
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)

# Note: gMSA account name ends with $
$principal = New-ScheduledTaskPrincipal -UserId "DOMAIN\MyGmsa$" -LogonType Password -RunLevel Highest

Register-ScheduledTask -TaskName "CredUnifiedTestGmsa" -Action $action -Trigger $trigger -Principal $principal
Start-ScheduledTask -TaskName "CredUnifiedTestGmsa"


👉 Key detail:

• Use DOMAIN\MyGmsa$ as the UserId.
• -LogonType Password is required for gMSA scheduled tasks (Windows handles the password automatically).


---

✅ Recommended Flow

1. Place CredUnifiedTest.ps1 in D:\Scripts.
2. Run the service account task → check D:\Logs\SmokeTestOutput.txt and D:\Logs\CredUnifiedTest.log.
3. Run the gMSA task → confirm the same outputs appear, proving the gMSA context executed the script.








