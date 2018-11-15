#!/bin/bash

DATE=`date +%Y%m%d`

curl https://www.nseindia.com/live_market/dynaContent/live_analysis/oi_spurts/topPositiveOIChangeData.json > oi/$DATE.csv

#Delivery
echo "Record Type,Sr No,Name of Security, Type of Security, Quantity Traded,Deliverable Quantity(gross across client level),% of Deliverable Quantity to Traded Quantity" > temp.csv
sed '1,4d' delivery/$DATE.csv >> temp.csv
mv temp.csv delivery/$DATE.csv

#OI
echo "Symbol, LatestOI, PrevOI, OIChange, %OIChange, Volume, IsFO" > temp.csv
curl https://nseindia.com/archives/equities/mto/MTO_`date +%d%m%Y`.DAT | jq -r '.data[] | [.symbol, .latestOI, .prevOI, .oiChange, .percOIchange, .volume, .isFO] | @csv' >> temp.csv
mv temp.csv oi/$DATE.csv

#OHL/FO
echo "Symbol, Open, High, Low, LTP, Change(InPts), Change(%), 52 Week High, 52 Week Low, Change in 365 days (%), Change in 30 days(%), Ex-Dividend-Date, Divident" > temp.csv
curl https://www.nseindia.com/live_market/dynaContent/live_watch/stock_watch/foSecStockWatch.json | jq -r '.data[] | [.symbol, .open, .high, .low, .ltP, .ptsC, .per, .wkhi, .wklo, .yPC, .mpC, .xDt, .cAct] | @csv' | sort >> temp.csv
mv temp.csv ohl/fo/$DATE.csv


git config credential.helper 'cache --timeout=120'
git config user.email "<email>"
git config user.name "Bot"
git add .
git commit -m "[skip travis] Data for $DATE"
git push https://${REPORTS_PERSONAL_TOKEN}@github.com/himanshu0503test/stock-reports.git master
echo "Committed Successfully"
