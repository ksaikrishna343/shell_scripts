#!/bin/sh

echo "Please talk to me ..."
while :
do
  read -p "Please enter your name: " NAME
  case $NAME in
	hello)
		echo "Hello yourself!"
                break
		;;
	bye)
		echo "See you again!"
		break
		;;
	*)
		echo -e  "Your name is noted as $NAME.\n\nThank you..!"
                break
		;;
  esac
done
echo 
echo "That's all folks!"
