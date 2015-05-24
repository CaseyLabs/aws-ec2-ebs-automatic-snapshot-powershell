#############################################################
#
# POWERSHELL: EBS Automatic Snapshot - Part #1: DISKSHADOW Component
# By Casey Labs Inc. Diskshadow commands contributed by phiber232.
# Github repo: https://github.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-powershell
#
############################################################

Set-StrictMode -Version Latest

# User variables: Set file locations
$diskshadowscript = "C:\aws\diskshadow.txt"
$runbackupscript = "C:\aws\2-run-backup.cmd"

# Gather list of local disks that aren't instance stores
$drives = Get-WmiObject -Class Win32_LogicalDisk | where {$_.VolumeName -notlike "Temporary Storage*"} |  where {$_.DriveType -eq '3'} | Select-Object DeviceID

# Output diskshadow commands to a text file
$scriptTxt = $scriptTxt + "begin backup" + "`n"
$drives | ForEach-Object { $scriptTxt = $scriptTxt + "add volume " + $_.DeviceID + "`n" }
$scriptTxt = $scriptTxt + "create" + "`n"
$scriptTxt = $scriptTxt + "exec $runbackupscript" + "`n"
$scriptTxt = $scriptTxt + "end backup" + "`n"
$scriptTxt | Set-Content $diskshadowscript

# Run diskshadow with our new script file
diskshadow /s $diskshadowscript