Write-Output "Welcome to the PC Health Checker"
Write-Output "This script will check the health status of sections of your computer and alert anything that needs to be fixed"

$outputColor = "Blue"
$errorColor = "Red"
$warningColor = "Yellow"
$fineColor = "Green"


#Checking PC Uptime
$pcUptime = Get-Uptime

# Check uptime and give status message
switch ($pcUptime.Days) {
    { $_ -le 4 } { Write-Host "Your computer uptime is fine" -ForegroundColor $fineColor; break }
    { $_ -le 6 } { Write-Host "Your current uptime is $($pcUptime.Days) you should restart soon" -ForegroundColor $warningColor; break } 
    { $_ -ge 7 } { Write-Host "Your current uptime is $($pcUptime.Days) you should restart asap" -ForegroundColor $errorColor; break }
    Default {}
}


#Checking Disk Health
Write-Host "Checking Disk Health" -ForegroundColor $outputColor

# Run chkdsk on C: drive
$chkdsk = chkdsk C:

# Check if there were errors
if ($chkdsk -match "errors found") {
    Write-Host "ERROR: Chkdsk found errors on C: drive" -ForegroundColor $errorColor
}
else {
    Write-Host "Chkdsk found C: drive to be healthy"  -ForegroundColor $fineColor
}

# Check free space
$freeSpaceGB = [Math]::Round($cDrive.FreeSpace / 1GB)
$totalSpaceGB = [Math]::Round($cDrive.Size / 1GB)

# Check if free space is less than 10% of total
if ($freeSpaceGB -lt ($totalSpaceGB * 0.1)) {
    Write-Host "WARNING: C: drive free space is less than 10% of total capacity"  -ForegroundColor $errorColor
}
else {
    Write-Host "C: drive free space check OK" -ForegroundColor $fineColor
}

# Network Health
Write-Host "Checking Network Health" -ForegroundColor $outputColor

$internetConnection = Test-Connection -ComputerName www.google.com -Count 4 -Quiet

if ($internetConnection) {
    Write-Host "Internet connection is OK" -ForegroundColor $fineColor

    # Asks if they would like the check for windows updates
    $userConfirmation = Read-Host "Would you like to check for Windows Updates? (Y/N)"
    if ($userConfirmation -eq "y") {
        #Checking for Windows Updates
        Write-Host "Checking for Windows Updates" -ForegroundColor $outputColor

        # Get Windows Update session
        $session = New-Object -ComObject Microsoft.Update.Session

        # Initialize update searcher
        $searcher = $session.CreateUpdateSearcher()

        # Search for updates
        $searchResult = $searcher.Search("IsInstalled=0 and Type='Software'")

        # Get list of available updates
        $availableUpdates = $searchResult.Updates

        # Print number of available updates
        Write-Host $availableUpdates.Count "updates available" -ForegroundColor $errorColor

        # Print update titles
        $availableUpdates | ForEach-Object {
            Write-Host $_.Title
        }

        if ($availableUpdates.Count -ge 1) {
            $userConfirmation = Read-Host "Would you like to install these updates? (Y/N)"
            if ($userConfirmation -eq "y") {
                Write-Host "Installing updates" -ForegroundColor $fineColor
                $downloader = $session.CreateUpdateDownloader()
                $downloader.Updates = $availableUpdates
                $downloader.Download()
                $installer = $session.CreateUpdateInstaller()
                $installer.Updates = $availableUpdates
                Write-Host "Updates installed, please restart your computer when able" -ForegroundColor $fineColor
            }
        }
    }

}
else {
    Write-Host "ERROR: No internet connection" -ForegroundColor $errorColor
    Write-Host "Would you like to attempt to repair the network? (Y/N)"
    $userConfirmation = Read-Host "Would you like to attempt to repair the network? (Y/N)"
    if ($userConfirmation -eq "y") {
        Write-Host "Attempting to repair network" -ForegroundColor $fineColor
        # Restart Network

        $networkAdapters = Get-NetAdapter 

        foreach ($adapter in $networkAdapters) {

            $adapterName = $adapter.Name
  
            Write-Output "Restarting network adapter: $adapterName"

            Disable-NetAdapter -Name $adapterName -Confirm:$false
            Enable-NetAdapter -Name $adapterName -Confirm:$false

        }

        Write-Host "Network reset complete." -ForegroundColor $outputColor
        Write-Host "Checking Network Health Again" -ForegroundColor $outputColor

        # Test if connected to internet
        $internetConnection = Test-Connection -ComputerName www.google.com -Count 1 -Quiet 

        if ($internetConnection) {
            Write-Output "Internet connection detected! rerun this script if you would like to check for Windows Updates" -ForegroundColor $fineColor
        }
        else {
            Write-Output "No internet connection detected, you will need to try to fix this yourself."  -ForegroundColor $errorColor
        }


    }
}





# Checking for services not running
Write-Host "Checking for services not running" -ForegroundColor $outputColor

# List of services to check, more can be added if needed
$services = @("wuauserv", "bits", "winrm", "spooler", "wscsvc")

foreach ($service in $services) {

    $status = Get-Service -Name $service

    if ($status.Status -ne "Running") {
        Write-Host "Service $($status.Name) is not running. Current status: $($status.Status)" -ForegroundColor $errorColor
        $userConfirmation = Read-Host "Would you like to start the service? (Y/N)"
        if ($userConfirmation -eq "y") {
            Start-Service -Name $service
            Write-Host "Service $($status.Name) started" -ForegroundColor $fineColor
        }
    }
    else {
        Write-Host "Service $($status.Name) is running" -ForegroundColor $fineColor
    }

}

# Checking for processes not running
Write-Output "Checking for processes not running"

# List of processes to check
$processes = @("explorer", "svchost", "Code") 

foreach ($process in $processes) {

    if (!(Get-Process -Name $process -ErrorAction SilentlyContinue)) {
        Write-Host "Process $process is NOT running" -ForegroundColor $errorColor
        $userConfirmation = Read-Host "Would you like to start the process? (Y/N)"
        if ($userConfirmation -eq "y") {
            Start-Process -FilePath $process
            Write-Host "Process $process started" -ForegroundColor $fineColor
        }
    }
    else {
        Write-Host "Process $process is running" -ForegroundColor $fineColor
    }

}

#Running SFC scannow to find windows corruption

Write-Host 'Running SFC scan' -ForegroundColor $outputColor

# Run SFC scan
$sfc = sfc /scannow

# Check output for errors
if ($sfc -match 'Found violations') {
    # Log error 
    $sfc | Out-File C:\logs\sfc-scan.txt
    Write-Host 'SFC scan found violations, please check C:\logs\sfc-scan.txt for more details' -ForegroundColor $errorColor
}
else {
    # Log clean scan 
    Write-Host 'SFC scan completed without errors' -ForegroundColor $fineColor
}


Write-Host -ForegroundColor $outputColor "Script completed"
Read-Host -Prompt "Press Enter to exit"
