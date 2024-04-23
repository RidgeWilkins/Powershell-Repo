Clear-Host

Write-Output "Welcome to the PC Health Checker"
Write-Output "This script will check the health status of sections of your computer and alert anything that needs to be fixed"

$pcUptime = Get-Uptime

switch ($pcUptime.Days) {
    { $_ -le 4 } { Write-Output "Your computer uptime is fine" ; break }
    { $_ -le 6 } { Write-Output "Your current uptime is $($pcUptime.Days) you should restart soon"; break }
    { $_ -ge 7 } { Write-Output "Your current uptime is $($pcUptime.Days) you should restart asap"; break }
    Default {}
}

Write-Output "HDD Check starting"
$drive = chkdsk C: | Select-String -Pattern "fixed" | Out-String
Write-Output "HDD Check complete"



