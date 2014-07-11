
#######################################################################
#
## POWERSHELL: Automatic EBS Volume Snapshot Creation & Clean-Up Script
#
# Written by Casey Labs Inc. (http://www.caseylabs.com)
# Casey Labs - Contact us for all your Amazon Web Services Consulting needs!
#
# PURPOSE: This Powershell script can be used to take automatic snapshots of your Windows EC2 instance. Script process:
# - Determine the instance ID of the EC2 server on which the script runs
# - Gather a list of all volume IDs attached to that instance
# - Take a snapshot of each attached volume
# - The script will then delete all associated snapshots taken by the script that are older than 7 days
#
# DISCLAMER: The software and service is provided by the copyright holders and contributors "as is" and any express or implied warranties, 
# including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose are disclaimed. In no event shall
# the copyright owner or contributors be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including, but
# not limited to, procurement of substitute goods or services; loss of use, data, or profits; or business interruption) however caused and on any
# theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way out of the use of this
# software or service, even if advised of the possibility of such damage.
#
# NON-LEGAL MUMBO-JUMBO DISCLAIMER: Hey, this script deletes snapshots (though only the ones that it creates)!
# Make sure that you undestand how the script works. No responsibility accepted in event of accidental data loss.
# 
#######################################################################

## SCRIPT REQUIREMENTS:
#
## IAM USER:
#
# This script requires that a new user (e.g. ebs-snapshot) be created in the IAM section of AWS. 
# Here is a sample IAM policy for AWS permissions that this new user will require:
#
#{
#  "Statement": [
#    {
#      "Sid": "Stmt1345661449962",
#      "Action": [
#        "ec2:CreateSnapshot",
#        "ec2:DeleteSnapshot",
#        "ec2:CreateTags",
#        "ec2:DescribeInstanceAttribute",
#        "ec2:DescribeInstanceStatus",
#        "ec2:DescribeInstances",
#        "ec2:DescribeSnapshotAttribute",
#        "ec2:DescribeSnapshots",
#        "ec2:DescribeVolumeAttribute",
#        "ec2:DescribeVolumeStatus",
#        "ec2:DescribeVolumes",
#        "ec2:ReportInstanceStatus",
#        "ec2:ResetSnapshotAttribute"
#      ],
#      "Effect": "Allow",
#      "Resource": [
#        "*"
#      ]
#    }
#  ]
#}

## AWS CLI:
# This script requires the AWS CLI tools to be installed on the target Windows instance.
# Download the Windows installer for AWS CLI at: https://aws.amazon.com/cli/
# 
# Next, configure AWS CLI by opening a command prompt on the Window server and running this command: 
# [ASSUMPTION: This command is being run under the local administrator account.]
#		aws configure
#
# Access Key & Secret Access Key: enter in the credentials generated above for the new IAM user
# Region Name: the region that this instance is currently in.
# Output Format: enter "text"

## SETUP SCRIPT SCHEDULED TASK
#
# Copy this script to your chosen location (e.g. C:\aws\ebs-snapshot.ps1)
#
# Next, create a batch file in the same directory (e.g. C:\aws\run-backup.cmd)
# Edit run-backup.cmd and enter these commands (with the appropriate local admin name and file locations, and without the #'s):
#
# set USERPROFILE=C:\Users\Administrator\
# powershell.exe -ExecutionPolicy Bypass -file "C:\aws\ebs-snapshot.ps1"
#
# Save the file. [Why do we have this separate batch script? Because in Windows 2012, the Task Scheduler passes the Default User environment
# variables, and therefore can't get the admin user's AWS credentials.]
#
# Next, open Task Scheduler on the server, and create a new task that runs C:\aws\run-backup.cmd on a nightly basis.


## BEGIN START OF SCRIPT ##

## SET VARIABLES
$curl = New-Object System.Net.WebClient
$instance_id = $curl.DownloadString("http://169.254.169.254/latest/meta-data/instance-id")
$hostname = hostname
$today = Get-Date -format yyyy-MM-dd

# How many days do you wish to retain backups for? Default: 7 days
$retention_days = "7"

# Where to store script log/temp files
$logfile = "C:\Windows\Logs\ebs-snaphots.txt"
$tmp_vol_info = "C:\Windows\Logs\volume_info.txt"
$tmp_snapshot_info = "C:\Windows\Logs\snapshot_info.txt"

# Start log file: today's date
if (!(test-path $logfile))
	{ New-Item $logfile -type file }

Add-Content $logfile "$today"

# Grab all volume IDs attached to this instance, and export the IDs to a text file
aws ec2 describe-volumes --filters Name="attachment.instance-id,Values=$instance_id" --query Volumes[].VolumeId --output text  | %{$_ -replace "`t","`n"} | out-file $tmp_vol_info

# Take a snapshot of all volumes attached to this instance
$volume_list = @()
$volume_list = get-content $tmp_vol_info
foreach($volume_id in $volume_list) {
	$description="$hostname-backup-$today"
	Add-Content $logfile "Volume ID is $volume_id"
    
	# Next, we're going to take a snapshot of the current volume, and capture the resulting snapshot ID
	$snapresult = aws ec2 create-snapshot --output=text --description $description --volume-id $volume_id --query SnapshotId
	
    Add-Content $logfile "New snapshot is $snapresult"
         
    # And then we're going to add a "CreatedBy:AutomatedBackup" tag to the resulting snapshot.
    # Why? Because we only want to purge snapshots taken by the script later, and not delete snapshots manually taken.
    aws ec2 create-tags --resource $snapresult --tags Key="CreatedBy,Value=AutomatedBackup"
	}

# Get all snapshot IDs associated with each volume attached to this instance
foreach($volume_id in $volume_list) {
	aws ec2 describe-snapshots --output=text --filters "Name=volume-id,Values=$volume_id" "Name=tag:CreatedBy,Values=AutomatedBackup" --query Snapshots[].SnapshotId | %{$_ -replace "`t","`n"} | out-file $tmp_snapshot_info
	}

# Purge all instance volume snapshots created by this script that are older than 7 days
$snapshot_list = @()
$snapshot_list = get-content $tmp_snapshot_info
foreach($snapshot_id in $snapshot_list) {
    Write-Host "Checking $snapshot_id..."
	$snapshot_date = aws ec2 describe-snapshots --output=text --snapshot-ids $snapshot_id --query Snapshots[].StartTime | %{$_.split('T')[0]}
    
	$snapshot_age = (get-date $today) - (get-date $snapshot_date)  | select-object Days | foreach {$_.Days}
	
    if ($snapshot_age -gt $retention_days) {
	    Add-Content $logfile "Deleting snapshot $snapshot_id ..."
        aws ec2 delete-snapshot --snapshot-id $snapshot_id
		}
    else {
        Add-Content $logfile "Not deleting snapshot $snapshot_id ..."
		}
	}
	
# One last carriage-return in the logfile...
Add-Content $logfile "`n"

Write-Host "Results logged to $logfile"
