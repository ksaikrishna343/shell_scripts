#!/bin/bash

# user input is needed i.e interactive script

echo "please enter user name"
read USER
echo "The user name is $USER"

read -p "Username:" uservar
read -sp "Password:" passvar  # -sp -> supress print

echo
echo "Thank you $uservar. Now we have your login details"

echo
echo "Enter your Name, Profession & Interests insame order seprated by a space?"
read name
read profession
read interest
echo Your entered name is: $name
echo Your profession is: $profession
echo Your are interested in: $interest
