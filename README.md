aws-ec2-ebs-automatic-snapshot-powershell
===================================

####Powershell script for Automatic EBS Snapshots and Cleanup on Amazon Web Services (AWS)

Written by **[AWS Consultants - Casey Labs Inc.] (http://www.caseylabs.com)**

*Casey Labs - Contact us for all your Amazon Web Services Consulting needs!*

===================================

**How it works:**
These scripts will:
- Start diskshadow on your instance, in order to keep disk consistency.
- Determine the instance ID of the EC2 server on which the script runs.
- Gather a list of all volume IDs attached to that instance.
- Take a snapshot of each attached volume
- The script will then delete all associated snapshots taken by the script that are older than 7 days
- Stop diskshadow to allow disk writes again.


Pull requests greatly welcomed!

===================================

**REQUIREMENTS**

**IAM User:** This script requires that a new user (e.g. ebs-snapshot) be created in the IAM section of AWS.  
Here is a sample IAM policy for AWS permissions that this new user will require:

```
{
  "Statement": [
    {
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
[**ASSUMPTION:** This command is being run under the local ADMINISTRATOR account.]
```
C:\Users\Administrator> aws configure
```

_Access Key & Secret Access Key:_ enter in the credentials generated above for the new IAM user.  
_Region Name:_ the region that this instance is currently in.  
_Output Format:_ enter "text"  

<br />
**SETUP SCRIPT SCHEDULED TASK**

1) [Download the scripts from Github] (https://github.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-powershell/archive/master.zip)

2) Extract the zip contents to **C:\aws** on your Windows Server

3) Next, open Task Scheduler on the server, and create a new task that runs:

powershell.exe -ExecutionPolicy Bypass -file "C:\aws\3-ebs-snapshot.ps1"

...on a nightly basis.
