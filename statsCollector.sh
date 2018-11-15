#!/bin/bash
DATE=`date +%Y%m%d`

curl https://www.nseindia.com/live_market/dynaContent/live_analysis/oi_spurts/topPositiveOIChangeData.json > oi/$DATE.json
curl https://nseindia.com/archives/equities/mto/MTO_`date +%d%m%Y`.DAT > delivery/$DATE.csv

echo "Record Type,Sr No,Name of Security, Type of Security, Quantity Traded,Deliverable Quantity(gross across client level),% of Deliverable Quantity to Traded Quantity" > temp.csv
sed '1,4d' delivery/$DATE.csv >> temp.csv
mv temp.csv delivery/$DATE.csv

git config credential.helper 'cache --timeout=120'
git config user.email "<email>"
git config user.name "Bot"
git add .
git commit -m "Data for $DATE"
git push -q https://${REPORTS_PERSONAL_TOKEN}@github.com/himanshu0503test/stock-reports.git master
