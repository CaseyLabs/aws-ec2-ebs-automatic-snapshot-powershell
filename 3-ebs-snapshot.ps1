#############################################################
#
# POWERSHELL: EBS Automatic Snapshot - Part #3: Snapshot Component
# By Casey Labs Inc.
# Github repo: https://github.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-powershell
#
############################################################


## Set User-Defined Variables
# How many days do you wish to retain backups for? Default: 7 days
$retention_days = "7"

## Set Variables
Set-StrictMode -Version Latest
$nl = [Environment]::NewLine
$volume_list = @()
$snapshot_list = @()
$global:log_message = $null
$hostname = hostname
$today = Get-Date -format yyyy-MM-dd
$curl = New-Object System.Net.WebClient
$instance_id = $curl.DownloadString("http://169.254.169.254/latest/meta-data/instance-id")
$region = $curl.DownloadString("http://169.254.169.254/latest/meta-data/placement/availability-zone")
$region = $region.Substring(0,$region.Length-1)


## Function Declarations

# Check if an event log source for this script exists; create one if it doesn't.
function logsetup {
	if (!([System.Diagnostics.EventLog]::SourceExists('EBS-Snapshot')))
		{ New-Eventlog -LogName "Application" -Source "EBS-Snapshot" }
}

# Write to console and Application event log (event ID: 1337)
function log ($type) {
	Write-Host $global:log_message
	Write-EventLog –LogName Application –Source "EBS-Snapshot" –EntryType $type –EventID 1337 –Message $global:log_message
}

# Pre-requisite check: make sure AWS CLI is installed properly.
function prereqcheck {
	if ((Get-Command "aws.exe" -ErrorAction SilentlyContinue) -eq $null) {
		$global:log_message = "Unable to find aws.exe in your PATH.`nVisit http://aws.amazon.com/cli/ to download the AWS CLI tools."
		log "Error"
		break 
	}
}

# Snapshot all volumes attached to this instance.
function snapshot_volumes {
	foreach($volume_id in $volume_list)	{
		$description="$hostname-backup-$today"
		$global:log_message = $global:log_message + "Volume ID is $volume_id" + $nl
    
		# Take a snapshot of the current volume, and capture the resulting snapshot ID
		$snapresult = aws ec2 create-snapshot --region $region --output=text --description $description --volume-id $volume_id --query SnapshotId
		$global:log_message = $global:log_message + "New snapshot is $snapresult" + $nl
         
		# And then we're going to add a "CreatedBy:AutomatedBackup" tag to the resulting snapshot.
		# Why? Because we only want to purge snapshots taken by the script later, and not delete snapshots manually taken.
		aws ec2 create-tags --region $region --resource $snapresult --tags Key="CreatedBy,Value=AutomatedBackup"
		$global:log_message = $global:log_message + "Volume ID is $volume_id." + $nl
	}
}

# Delete all attached volume snapshots created by this script that are older than $retention_days
function cleanup_snapshots {
	foreach($volume_id in $volume_list) {
		$snapshot_list = aws ec2 describe-snapshots --region $region --output=text --filters "Name=volume-id,Values=$volume_id" "Name=tag:CreatedBy,Values=AutomatedBackup" --query Snapshots[].SnapshotId | %{$_.split("`t")}
		foreach($snapshot_id in $snapshot_list) {
			$global:log_message = $global:log_message + "Checking $snapshot_id..." + $nl
			$snapshot_date = aws ec2 describe-snapshots --region $region --output=text --snapshot-ids $snapshot_id --query Snapshots[].StartTime | %{$_.split('T')[0]}
			$snapshot_age = (get-date $today) - (get-date $snapshot_date)  | select-object Days | foreach {$_.Days}
		
			if ($snapshot_age -gt $retention_days) {
				$global:log_message = $global:log_message + "Deleting snapshot $snapshot_id ..." + $nl
				aws ec2 delete-snapshot --region $region --snapshot-id $snapshot_id
			}
			else {
				$global:log_message = $global:log_message + "Not deleting snapshot $snapshot_id ..." + $nl
			}
		}
	}
}

## START COMMANDS

# Initialization functions
logsetup
prereqcheck

$volume_list = aws ec2 describe-volumes --filters Name="attachment.instance-id,Values=$instance_id" --query Volumes[].VolumeId --output text | %{$_.split("`t")}

snapshot_volumes
cleanup_snapshots

# Write output to Event Log
log "Info"
write-host "Script complete. Results written to the Event Log (check under Applications, Event ID 1377)."