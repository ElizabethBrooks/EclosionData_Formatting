#!/bin/bash

#Remove header
tail -n +2 "$1" > tmpDataIn.csv

#Remove excess tags from Fly_Para column
cut -d "," -f 7 tmpDataIn.csv > tmpFly.csv
sed -i "s/fly.*/fly/g" tmpFly.csv

#Add updated Fly_Para column to the data set
cut -d "," -f 1-6 tmpDataIn.csv > tmpFirstHalf.csv
cut -d "," -f 8,9 tmpDataIn.csv > tmpSecondHalf.csv
paste -d',' tmpFirstHalf.csv tmpFly.csv tmpSecondHalf.csv > tmpDataIn.csv

#Sort the file
sort -t"," -k3,3 -k6,6 -k7,7 < tmpDataIn.csv > tmpDataSorted.csv

#Initialize variables
lastHost="INITIALIZE"
lastEclose="INITIALIZE"
lastFly=0
newN=0
COUNTER=0
#Loop over dates and calc differences
while IFS=, read -r f1 f2 f3 f4 f5 f6 f7 f8 f9
do
	#Check if first entry
	if [[ $COUNTER == 0 ]]; then
		#Set output N to current N
		newN=$(echo "$f8" | bc -l)
	else
		#Determine if new entry
		if [[ $f3 == $lastHost && $f6 == $lastEclose && $f7 == $lastFly ]]; then
			#Sum ouput N
			currN=$(echo "$f8" | bc -l)
			newN=$(echo "$newN+$currN" | bc -l)
		else
			#Output previous N
			echo $f3,$f6,$f7,$f1,$newN >> tmpDataOut.csv
			#Set output N to current N
			newN=0
			newN=$(echo "$f8" | bc -l)
		fi
	fi
	#Set last enries
	lastHost=$f3
	lastEclose=$f6
	lastFly=$f7
	lastDays=$f1
	#Increment counter
	COUNTER=$(($COUNTER+1))
done < tmpDataSorted.csv

#Retrieve second to last entry
tail -n 2 tmpDataSorted.csv | head -1 > tmpDataEnding.csv

#Set next to last entries
nextLastHost=$(cut -d "," -f 3 tmpDataEnding.csv)
nextLastEclose=$(cut -d "," -f 6 tmpDataEnding.csv)
nextLastFly=$(cut -d "," -f 7 tmpDataEnding.csv)

#Output last N if not new entry
if [[ $nextLastHost == $lastHost && $nextLastEclose == $lastEclose && $nextLastFly == $lastFly ]]; then
	echo $lastHost,$lastEclose,$lastFly,$lastDays,$newN >> tmpDataOut.csv
fi

#Create header for output file
head -1 "$1" > tmpHeader.csv
headerHost=$(cut -d "," -f 3 tmpHeader.csv)
headerEclose=$(cut -d "," -f 6 tmpHeader.csv)
headerFly=$(cut -d "," -f 7 tmpHeader.csv)
headerDays=$(cut -d "," -f 1 tmpHeader.csv)
headerN="Sum_N"
echo $headerHost,$headerEclose,$headerFly,$headerDays,$headerN > tmpHeader.csv

#Add header to output file
fileOut=$(basename "$1" | sed "s/\.csv//g") 
cat tmpHeader.csv tmpDataOut.csv > "$fileOut"_summedN.csv

#Clean up
rm tmp*.csv