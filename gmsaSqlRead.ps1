# Define variables
$folderPath = "C:\Data\CSVFiles"          # Folder containing your CSV files
$gmsaAccount = "DOMAIN\SqlSvcGmsa$"       # Replace with your actual gMSA (note the $ at the end)

# Grant NTFS permissions (Read & Execute, List Folder Contents, Read)
$acl = Get-Acl $folderPath
$permission = "$gmsaAccount","ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $folderPath $acl

Write-Host "Granted read access to $gmsaAccount on $folderPath ✅"
