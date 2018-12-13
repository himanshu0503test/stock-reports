#! /bin/bash
DATE=`date +%Y%m%d`

echo "Symbol, Type, Traded Volume, Delivery, Delivery(%)" > temp-delivery.csv
awk -F "\"*,\"*" '{print $3","$4","$5","$6","$7 }' delivery/$DATE.csv | grep 'EQ'>> temp-delivery.csv

{
  echo "Symbol, Type, Traded Volume, Delivery, Delivery(%), LatestOI, PrevOI, OIChange, %OIChange, Volume"
  join -t, <(sed 1d "temp-delivery.csv" | sort) <(sed 1d "oi/$DATE.csv" | sort)
} > d04.csv


{
  echo "Symbol, Type, Traded Volume, Delivery, Delivery(%), LatestOI, PrevOI, OIChange, %OIChange, Volume, Open, High, Low, LTP, Price Change(InPts), Price Change(%), 52 Week High, 52 Week Low, Change in 365 days (%), Change in 30 days(%), Date, Announcement"
  join -t, <(sed 1d "d04.csv" | sort) <(sed 1d "ohl/fo/$DATE.csv" | sort)
} > d05.csv

awk -F ',' '{print $1","$5","$4","$9","$16}' d05.csv > $DATE.csv
rm d04.csv d05.csv temp-delivery.csv