# ============================================
# OFFLINE PREP & INSTALL SCRIPT
# SQL Client Tools + (optional) Visual Studio Community
# ============================================

# --- Create staging folder for installers ---
$dest = "C:\OfflineInstallers"
New-Item -ItemType Directory -Force -Path $dest

# ============================
# DOWNLOAD SECTION (run on online machine)
# ============================

# --- SQL Server Management Studio (SSMS) ---
# Includes SQLCMD and client libraries
Invoke-WebRequest -Uri "https://aka.ms/ssmsfullsetup" -OutFile "$dest\SSMS-Setup-ENU.exe"

# --- ODBC Driver for SQL Server (example: v18) ---
Invoke-WebRequest -Uri "https://download.microsoft.com/download/9/6/8/968C0A4E-8E3E-4C0F-9C9A-7B6B7F9E0F3E/msodbcsql.msi" -OutFile "$dest\msodbcsql.msi"

# --- SQLCMD Command Line Utilities (CLI only, optional if SSMS installed) ---
Invoke-WebRequest -Uri "https://download.microsoft.com/download/9/6/8/968C0A4E-8E3E-4C0F-9C9A-7B6B7F9E0F3E/SqlCmdLnUtils.msi" -OutFile "$dest\SqlCmdLnUtils.msi"

# --- Azure Data Studio (optional lightweight GUI) ---
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2157190" -OutFile "$dest\azuredatastudio.zip"

# --- Visual Studio Community bootstrapper (optional, if you want VS workloads) ---
Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_community.exe" -OutFile "$dest\vs_community.exe"

# --- Create offline layout for Visual Studio Community (optional) ---
# Add workloads as needed (example: .NET desktop + Data tools)
Start-Process "$dest\vs_community.exe" -ArgumentList `
    "--layout $dest\VSLayout --lang en-US --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Data" -Wait

# ============================================
# INSTALLATION SECTION (run on offline VM)
# ============================================

# --- Unblock installers to bypass SmartScreen ---
Get-ChildItem $dest | Unblock-File

# --- Install SSMS silently ---
Start-Process "$dest\SSMS-Setup-ENU.exe" -ArgumentList "/install /quiet /norestart" -Wait

# --- Install ODBC driver silently ---
msiexec /i "$dest\msodbcsql.msi" /quiet /norestart

# --- Install SQLCMD utilities silently ---
msiexec /i "$dest\SqlCmdLnUtils.msi" /quiet /norestart

# --- Extract Azure Data Studio ---
Expand-Archive "$dest\azuredatastudio.zip" -DestinationPath "C:\Program Files\Azure Data Studio"

# --- Install Visual Studio Community from offline layout (optional) ---
Start-Process "$dest\VSLayout\vs_installer.exe" -ArgumentList `
    "--installPath C:\VSCommunity --quiet --norestart" -Wait

# ============================================
# VERIFICATION SECTION
# ============================================

# --- Check if sqlcmd is available ---
Get-Command sqlcmd -ErrorAction SilentlyContinue

# --- Check installed ODBC drivers ---
Get-OdbcDriver | Where-Object Name -like "*SQL Server*"

# --- Check if SSMS is installed ---
Get-Item "C:\Program Files (x86)\Microsoft SQL Server Management Studio*\Common7\IDE\Ssms.exe" -ErrorAction SilentlyContinue

# --- Check if Azure Data Studio is installed ---
Get-Item "C:\Program Files\Azure Data Studio\azuredatastudio.exe" -ErrorAction SilentlyContinue
