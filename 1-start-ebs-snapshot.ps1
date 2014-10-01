#######################################################################
#
## POWERSHELL: EBS Automatic Snapshot - DISKSHADOW Component
#
# DISKSHADOW Script written by phiber232 (http://www.reddit.com/r/aws/comments/2hn57i/anyone_with_a_windows_server_on_ec2_how_are_you/ckvhfkx)
# Updated for Windows 2008 compatibility by Casey Labs Inc.
#
# PURPOSE: This script starts the diskshadow process to preserve disk consistency, then calls the EBS volume snapshot script. Process:
# - Gather a list of all local disks that are not S3 instances stores (i.e. "Temporary Storage").
# - Start diskshadow on each local disk.
# - Call the EBS snapshot script, and snapshot each volume.
# - End the diskshadow process, allowing writes to the disk again.
#
# DISCLAMER: The software and service is provided by the copyright holders and contributors "as is" and any express or implied warranties, 
# including, but not limited to, the implied warranties of merchantability and fitness for a particular purpose are disclaimed. In no event shall
# the copyright owner or contributors be liable for any direct, indirect, incidental, special, exemplary, or consequential damages (including, but
# not limited to, procurement of substitute goods or services; loss of use, data, or profits; or business interruption) however caused and on any
# theory of liability, whether in contract, strict liability, or tort (including negligence or otherwise) arising in any way out of the use of this
# software or service, even if advised of the possibility of such damage.
#
#######################################################################


# SET FILE LOCATIONS
$diskshadowscript = "C:\aws\diskshadow.txt"
$runbackupscript = "C:\aws\run-backup.cmd"

# Gather list of local disks that aren't instance stores
$nl = [Environment]::NewLine
$drives = Get-WmiObject -Class Win32_LogicalDisk | where {$_.VolumeName -notlike "Temporary Storage*"} | Select-Object DeviceID

# Output diskshadow commands to a text file
$scriptTxt = "# Diskshadow commands for EBS snapshots" + $nl
$scriptTxt = $scriptTxt + "begin backup" + $nl
$drives | ForEach-Object { $scriptTxt = $scriptTxt + "add volume " + $_.DeviceID + $nl }
$scriptTxt = $scriptTxt + "create" + $nl
$scriptTxt = $scriptTxt + "exec $runbackupscript" + $nl
$scriptTxt = $scriptTxt + "end backup" + $nl
$scriptTxt = $scriptTxt + "#End of Script" + $nl
$scriptTxt | Set-Content $diskshadowscript

# Run diskshadow with our new script file
diskshadow /s $diskshadowscript
