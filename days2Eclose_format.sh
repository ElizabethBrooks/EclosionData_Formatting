#!/bin/bash

#Remove header
tail -n +2 "$1" > tmpDataIn.csv

#Add header to diff column
echo "Eclose_Days" > tmpDataOut.csv
#Loop over dates and calc differences
while IFS=, read -r f1 f2 f3 f4 f5 f6 f7 f8
do
	#Retrieve eclose date
	ecloseDate=$(date -d "$f5" +%s)
	#Retriece pull date
	pullDate=$(date -d "$f4" +%s)
	#Calc difference
	diff=$((($ecloseDate-$pullDate)/86400))
	#Output to tmp file
	echo $diff >> tmpDataOut.csv
done < tmpDataIn.csv

#Add header to file
head -1 "$1" > tmpHeader.csv
cat tmpHeader.csv tmpDataIn.csv > tmpDataFormatted.csv

#Add differences to original file
fileOut=$(basename "$1" | sed "s/\.csv//g") 
paste -d',' tmpDataOut.csv tmpDataFormatted.csv > "$fileOut"_ecloseDays.csv

#Clean up
rm tmp*.csv