# User_Management_HNG11
# User Management Script

This repository contains a Bash script to automate the creation of users and groups on a Unix-like system.

## Files

- `create_users.sh`: The Bash script to create users and groups.
- `README.md`: This file.

## Script Usage

1. **Ensure the script is executable**:
   ```bash
   chmod +x create_users.sh

	2.	Run the script with a user file:

sudo ./create_users.sh /path/to/user_file.txt

		3.	The user_file.txt should contain lines formatted as follows:

username; group1, group2, group3

		Example user_file.txt:

		light; sudo, dev, www-data
		idimma; sudo
		mayowa; dev, www-data

Script Details

	•	Logs: Actions are logged to /var/log/user_management.log.
	•	Passwords: Generated passwords are stored in /var/secure/user_passwords.txt.

Prerequisites

	•	Unix-like operating system (Linux)
	•	whois package (for mkpasswd command):

sudo apt-get update
sudo apt-get install whois
