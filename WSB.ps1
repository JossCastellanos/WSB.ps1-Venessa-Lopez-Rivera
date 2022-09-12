param (
    [string]$time = "23:00"
)

#checks if the feature is installed, if it is not installed, runs the next command to install it.
$WSB = Get-WindowsFeature -name Windows-Server-Backup

if ($WSB.Installed -ne "True") {
    Add-WindowsFeature - Name Windows-Server-Backup
}

#Command gets the credentials
$cred = Get-Credential OHMSERVER\Administrator

#Command creates a backup policy object and stores it in the $Policy variable.
$Policy = New-WBPolicy
#Command adds system state recovery to the policy.
$Policy = Add-WBSystemState

#Command gets the windows Backup disk configuration
#Cmdlet gets the list of critical volumes available for the local computer and stores the resulting list 
# in the $Volumes variables
$Volumes = Get-WBVolume -CriticalVolumes
Add-WBVolume -Policy $Policy -Volume $Volumes

#Command creates a backup target object and stores it in the $BackupLocation variable.
$BackupLocation = New-WBBackupTarget - NetworkPath "\\LON-DC\Backup" -Credential $cred
Add-WBBackupTarget -Policy $Policy -Target $BackupLocation

#Command sets the backup schedule in the policy. The cmdlet sets the time to create daily backups.
Set-WBSchedule -Policy $Policy -Schedule $time

#Command sets the backup schedule in the policy object for the computer
Set-WBPolicy -Policy $Policy
#Print on the screen these sentences and this piece of code checks if the task will be run at 11:PM and thus
# show the status
Write-Host "Backup configures at: $time"
Write-Host "Waiting for backup execution"

if ($time -ne "23:00") {
    While ($true) {
        $summary = Get-WBSummary

        Write-Host "Backup status: $($summary.CurrentOperationStatus)"

        Start-Sleep -s 10
    }
}
