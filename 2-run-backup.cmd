# Intermediary batch script - called by the Disk Shadow script.
#
# Why do we also have this separate batch script to call the EBS snapshot script? 
# Because in Windows 2012, the Task Scheduler passes the Default User environment variables, 
# and therefore can't get the admin user's AWS credentials.

# NOTE: if you configured the AWS credentials under a user other than the Administrator account, you will need to set
# the USERPROFILE below to match that user's home directory.
set USERPROFILE=C:\Users\Administrator\

powershell.exe -ExecutionPolicy Bypass -file "C:\aws\3-ebs-snapshot.ps1"
