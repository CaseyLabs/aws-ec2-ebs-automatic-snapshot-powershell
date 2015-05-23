#############################################################
#
# EBS Automatic Snapshot - Part #2: Intermeditary Script
# By Casey Labs Inc.
# Github repo: https://github.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-powershell
#
############################################################

# Intermediary batch script - called by the Disk Shadow script.
#
# NOTE: if you configured the AWS credentials under a Windows user other than the Administrator account, 
# you will need to set the USERPROFILE below to match that Window user's profile directory.

set USERPROFILE=C:\Users\Administrator\
powershell.exe -ExecutionPolicy Bypass -file "C:\aws\3-ebs-snapshot.ps1"
