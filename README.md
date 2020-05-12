# ckpt_update_threat_protections
Used to bulk update threat protections using API calls on a Check Point management server

## Instructions 
- This script is designed to be run on a Check Point management server
- Verify the API is up and running before execution, from CLI run: `api status` 
- Suggest running a test API show command before running, script does not currently have any verification built in

### Script setup
1. ssh into a Check Point log server as admin
1. enter expert mode
1. copy file [update_threat_protections.sh](https://raw.githubusercontent.com/joeaudet/ckpt_update_threat_protections/master/update_threat_protections.sh) to /home/admin/ on log server
   ```
   curl_cli -k https://raw.githubusercontent.com/joeaudet/ckpt_update_threat_protections/master/update_threat_protections.sh > /home/admin/update_threat_protections.sh
   ```
1. chmod the script to be executable
   ```
   chmod u+x /home/admin/update_threat_protections.sh
   ```
1. Make any modifications to the list of protections inside the script which are stored in a multi-line array
1. Update the variables inside the script for your environment
1. Run the script
   ```
   /home/admin/./update_threat_protections.sh
   ```