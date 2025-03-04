#!/bin/bash

# Script overview
# This script will be run assuming root access has already been received, either from other team members or by my own devices.
# This script will add 50 new users, all with admin privileges. They will all share a super strong password scheme, so I can get into them easier.
# This password scheme will be long enough that a cracker won't be able to get it.


# This is where it checks to see if it is being run with elevated permissions.
if [[ $EUID -ne 0 ]]; then
    echo "You need to run this script as root."
    echo "Try: sudo $0"
    exit 1
fi

# This is the number of users to create
NUM_USERS=50

# There is a default wordlist in Ubuntu. BE SURE TO CHECK IT IS THERE ON GREY TEAM INFRASTRUCTURE!
WORD_LIST="/usr/share/dict/words"

# This checks that the wordlist exists. This prevents stupid errors
if [[ ! -f "$WORD_LIST" ]]; then
    echo "Word list not found at $WORD_LIST. Please install it or provide a valid word list."
    exit 1
fi

# The loop to create users
for i in $(seq 1 $NUM_USERS); do
    # Generate a random word from the dictionary, and makes sure it is all lowercase.
    USERNAME=$(shuf -n 1 "$WORD_LIST" | tr '[:upper:]' '[:lower:]')

    # This makes sure that only unique usernames are added.
    while id "$USERNAME" &>/dev/null; do
        USERNAME=$(shuf -n 1 "$WORD_LIST" | tr '[:upper:]' '[:lower:]')
    done

    # Creates the user and some default settings related to their home directory and their login shell.
    useradd -m -s /bin/bash "$USERNAME"

    # Sets the user's password using my given password scheme. For the competition, I can make the password scheme more difficult tbh.
    PASSWORD="Secret Password ${USERNAME}"
    echo "$USERNAME:$PASSWORD" | chpasswd

    # Adds the user to sudo group
    usermod -aG sudo "$USERNAME"

    echo "Created user: $USERNAME with admin privileges."
done

echo "All users have been created successfully!"
