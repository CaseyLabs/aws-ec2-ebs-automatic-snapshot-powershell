REM #############################################################
REM #
REM # EBS Automatic Snapshot - Part #2: Intermeditary Script
REM # By Casey Labs Inc.
REM # Github repo: https://github.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-powershell
REM #
REM ############################################################

REM # Intermediary batch script - called by the Disk Shadow script.
REM #
REM # NOTE: if you configured the AWS credentials under a Windows user other than the Administrator account, 
REM # you will need to set the USERPROFILE below to match that Window user's profile directory.

set USERPROFILE=C:\Users\Administrator\
powershell.exe -ExecutionPolicy Bypass -file "C:\aws\3-ebs-snapshot.ps1"
