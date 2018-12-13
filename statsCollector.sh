#!/bin/bash

git checkout master
git pull origin master

DATE=`date +%Y%m%d`

#Delivery
curl https://nseindia.com/archives/equities/mto/MTO_`date +%d%m%Y`.DAT > delivery/$DATE.csv
echo "Record Type,Sr No,Name of Security, Type of Security, Quantity Traded,Deliverable Quantity(gross across client level),% of Deliverable Quantity to Traded Quantity" > temp.csv
sed '1,4d' delivery/$DATE.csv >> temp.csv
mv temp.csv delivery/$DATE.csv

#OI
echo "Symbol, LatestOI, PrevOI, OIChange, %OIChange, Volume" > temp.csv
curl https://www.nseindia.com/live_market/dynaContent/live_analysis/oi_spurts/topPositiveOIChangeData.json | jq -r '.data[] | [.symbol, .latestOI, .prevOI, .oiChange, .percOIchange, .volume] | @csv' | sort | awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' >> temp.csv
awk '{gsub(/\"/,"")};1' temp.csv > quotes-removed.csv
mv quotes-removed.csv oi/$DATE.csv
rm temp.csv

#OHL/FO
echo "Symbol, Open, High, Low, LTP, Change(InPts), Change(%), 52 Week High, 52 Week Low, Change in 365 days (%), Change in 30 days(%), Date, Announcement" > temp.csv
curl https://www.nseindia.com/live_market/dynaContent/live_watch/stock_watch/foSecStockWatch.json | jq -r '.data[] | [.symbol, .open, .high, .low, .ltP, .ptsC, .per, .wkhi, .wklo, .yPC, .mPC, .xDt, .cAct] | @csv' | sort | awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' >> temp.csv
awk '{gsub(/\"/,"")};1' temp.csv > quotes-removed.csv
mv quotes-removed.csv ohl/fo/$DATE.csv
rm temp.csv


git config credential.helper 'cache --timeout=120'
git config user.email "<email>"
git config user.name "Bot"
git add .
git commit -m "[skip travis] Data for $DATE"
git push https://${REPORTS_PERSONAL_TOKEN}@github.com/himanshu0503test/stock-reports.git master
echo "Committed Successfully"
