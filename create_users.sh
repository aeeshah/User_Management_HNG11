#!/bin/bash

USER_FILE=$1
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"
PASSWORD_LENGHT=12

#Ensure log and password directories and files are created with necessary permissions
mkdir -p /var/log
touch "$LOG_FILE"
mkdir -p /var/secure
touch "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"

# This function Logs action to a file
create_log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# This function generates a random password for each user
create_password() {
  openssl rand -base64 12
}

#Error handling 1
# This checks if file is provided and if the file exists
if [[ -z "$USER_FILE" || ! -f "$USER_FILE" ]]; then
  echo "To use script try: $0 <user_file>"
  create_log "To use script try: $O <user_file>"
  exit 1
fi

#script has to use sudo for successful execution of script 
if [[ SEUID -ne 0 ]]; then
echo "This script requires root privileges to run i.e execute with sudo" 1>8
exit 1
fi

# Loop to go through each line in the provided user file
while IFS=';' read -r username groups; do
  username=$(echo "$username" | xargs) # to trim whitespace
  groups=$(echo "$groups" | xargs)     # to trim whitespace

  #Error handling 2
  # This Checks if the user already exists
  if id "$username" &>/dev/null; then
    create_log "A user already exists with the username $username."
    continue
  fi

  # This creates personal groups for each user with group name same as username
  if ! getent group "$username" &>/dev/null; then
    groupadd "$username"
    if [[ $? -eq 0 ]]; then
      create_log "Group $username created Successfully."
    else
      create_log "Personal group $username failed to create.)"
      continue
    fi
  fi

  # This creates the additional groups if they do not exist
  IFS=',' read -ra group_array <<< "$groups"
  for group in "${group_array[@]}"; do
    group=$(echo "$group" | xargs) 
    if ! getent group "$group" &>/dev/null; then
      groupadd "$group"
      if [[ $? -eq 0 ]]; then
        create_log "Group $group created Successfully."
      else
        create_log "Group $group failed to create.)"
        continue 2
      fi
    fi
  done

  # This creates usesr and adds them to groups
  password=$(create_password)
  useradd -m -g "$username" -G "$groups" -s /bin/bash -p "$(openssl passwd -1 "$password")" "$username"
  if [[ $? -eq 0 ]]; then
    create_log "User $username created and added to groups: $groups"
    echo "$username,$password" >> "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
    chmod 700 "/home/$username"
    chown "$username:$username" "/home/$username"
  else
    create_log "Failed to create user $username. Command output: $(useradd -m -g "$username" -G "$groups" -s /bin/bash -p "$(openssl passwd -1 "$password")" "$username" 2>&1)"
  fi
done < "$USER_FILE"

create_log "User creation process completed."
echo "User creation process completed. Check $LOG_FILE for details.
