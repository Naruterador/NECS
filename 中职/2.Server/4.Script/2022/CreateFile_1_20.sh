#!/bin/bash
DIR="/root/test/"


if [ ! -d "$DIR" ]; 
then
	mkdir $DIR
else
	rm -rf $DIR
	mkdir $DIR
fi

FILE="File0"
for i in {1..9}
do
	if [ -f "$DIR$FILE$i" ]
	then
		rm -rf $DIR$FILE$i
		touch $DIR$FILE$i
	else
		touch $DIR$FILE$i
	fi	
        echo $FILE$i > $DIR$FILE$i
done

FILE="File"
for i in {10..20}
do
  	if [ -f "$DIR$FILE$i" ]
	then
		rm -rf $DIR$FILE$i
  		touch $DIR$FILE$i
	else
		touch $DIR$FILE$i
	fi
        echo $FILE$i > $DIR$FILE$i
done
