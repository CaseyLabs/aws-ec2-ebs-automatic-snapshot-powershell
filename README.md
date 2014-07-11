aws-ec2-ebs-automatic-snapshot-powershell
===================================

####Powershell script for Automatic EBS Snapshots and Cleanup on Amazon Web Services (AWS)

Written by **[AWS Consultants - Casey Labs Inc.] (http://www.caseylabs.com)**

*Casey Labs - Contact us for all your Amazon Web Services Consulting needs!*

===================================

**How it works:**
ebs-snapshot.ps1 will:
- Determine the instance ID of the EC2 server on which the script runs
- Gather a list of all volume IDs attached to that instance
- Take a snapshot of each attached volume
- The script will then delete all associated snapshots taken by the script that are older than 7 days


Pull requests greatly welcomed!

===================================

**REQUIREMENTS**

**IAM User:** This script requires that a new user (e.g. ebs-snapshot) be created in the IAM section of AWS. 
Here is a sample IAM policy for AWS permissions that this new user will require:

```
{
  "Statement": [
    {
      "Sid": "Stmt1345661449962",
      "Action": [
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:CreateTags",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshotAttribute",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumeAttribute",
        "ec2:DescribeVolumeStatus",
        "ec2:DescribeVolumes",
        "ec2:ReportInstanceStatus",
        "ec2:ResetSnapshotAttribute"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
```
<br />
**AWS CLI:** This script requires the AWS CLI tools to be installed on the target Windows instance.
Download the Windows installer for AWS CLI at: [https://aws.amazon.com/cli/] (https://aws.amazon.com/cli/)

Next, configure AWS CLI by opening a command prompt on the Window server and running this command: 
```
	aws configure
```

Access Key & Secret Access Key: enter in the credentials generated above for the new IAM user.
Region Name: the region that this instance is currently in.
Output Format: enter "text"
<br />
**SETUP SCRIPT SCHEDULED TASK**

Copy this script to your chosen location (e.g. C:\aws\ebs-snapshot.ps1)

Next, create a batch file in the same directory (e.g. C:\aws\run-backup.cmd)
Edit run-backup.cmd and enter these commands (with the appropriate local admin name and file locations):

```
set USERPROFILE=C:\Users\Administrator\
powershell.exe -ExecutionPolicy Bypass -file "C:\aws\ebs-snapshot.ps1"
```

Save the file. [Why do we have this separate batch script? Because in Windows 2012, the Task Scheduler passes the Default User environment variables, and therefore can't get the admin user's AWS credentials.]

Next, open Task Scheduler on the server, and create a new task that runs C:\aws\run-backup.cmd on a nightly basis.
