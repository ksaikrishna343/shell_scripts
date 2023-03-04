#!/bin/sh
# A simple script with a function...

add_a_user()
{
  USER=$1
  PASSWORD=$2
  shift; shift;
  # Having shifted twice, the rest is now comments ...
  COMMENTS=$@
  echo "Adding user $USER ..."
  useradd -p $(openssl passwd -1 $PASSWORD) $USER -c '"'"$COMMENTS"'"'
  #echo useradd -c "$COMMENTS" $USER
  #echo passwd $USER $PASSWORD
  echo "Added user $USER ($COMMENTS) with pass $PASSWORD"
}
###
# Main body of script starts here
###
echo "Start of script..."
add_a_user SAI sai1234 IT engineer
echo "End of script..."
