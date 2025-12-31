#!/bin/bash
DIR="/root/test/"


if [ ! -d "$DIR" ]; 
then
	mkdir $DIR
else
	rm -rf $DIR
	mkdir $DIR
fi

FILE="File"
for i in {101..120}
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
