aws-ec2-ebs-automatic-snapshot-powershell
===================================

####Powershell script for Automatic EBS Snapshots and Cleanup on Amazon Web Services (AWS) EC2

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

**IAM:** This script requires that an IAM User or IAM Role be created with the following policy attached:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1426256275000",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:DeleteSnapshot",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumes"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```
<br />
**AWS CLI:** This script requires the AWS CLI tools to be installed on the target Windows instance.  

- Log into your Windows instance with your local Administrator account.

- Download the Windows installer for AWS CLI at: [https://aws.amazon.com/cli/] (https://aws.amazon.com/cli/)

- Next, open a command prompt on the Window server and configure the AWS CLI (_Note: you can skip this step if your EC2 instance is configured with an IAM role_):   

```
C:\Users\Administrator> aws configure

AWS Access Key ID: (Enter in the IAM credentials generated above.)
AWS Secret Access Key: (Enter in the IAM credentials generated above.)
Default region name: (The region that this instance is currently in: i.e. us-east-1, eu-west-1, etc.)
Default output format: (Enter "text".)
```

<br />
**INSTALL SCRIPT AS A SCHEDULED TASK**

1) [Download the scripts from Github] (https://github.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-powershell/archive/master.zip)

2) Extract the zip contents to **C:\aws** on your Windows Server

3) Next, open Task Scheduler on the server, and create a new task that runs:
```
powershell.exe -ExecutionPolicy Bypass -file "C:\aws\1-start-ebs-snapshot.ps1"
```
...on a nightly basis.
