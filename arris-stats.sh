#!/bin/sh
# Script by graysky
# https://github.com/graysky2/bin/blob/master/arris_signals
#

# PREFACE
# This very trivial script will log the downstream/upstream power levels
# as well as the respective SNR from your Arris TM822 and related modem
# to individual csv values suitable for graphing in dygraphs[1].
#
# Use it to monitor power levels, frequencies, and SNR values over time to aid
# in troubleshooting connectivity with your ISP. The script is easily called
# from a cronjob at some appropriate interval (hourly for example).
#
# It is recommended that users simply call the script via a cronjob at the
# desired interval. Perhaps twice per hour is enough resolution.
#
# Note that the crude grep/awk/sed lines work fine on an Arris TM822G running
# Firmware            : TS070659C_050313_MODEL_7_8_SIP_PC20
# Firmware build time : Fri May 3 11:18:59 EDT 2013

# INSTALLATION
# 1. Place the script 'capture_arris_for_dygraphs.sh' in a directory of your
#    choosing and make it executable. Edit it to defining the correct path
#    for storage of the log files which need to be web-exposed for dygraph
#    to work properly.
#
# 2. Place 'dygraph-combined.js' and 'index.html' into the web-exposed dir you
#    defined in step #1.

# REFERENCES
# 1. https://github.com/danvk/dygraphs

###############               Configuration            #####################
# TEMP is the full path to the temp file wget will grab from your modem.
#      it is recommended to use something in tmpfs like /tmp for example.
TEMP=/tmp/snapshot.html

# LOGPATH is the full path to the log file you will keep.
LOGPATH=/tmp/mnt/router/optware/share/www/arris

# If you want to log all html snapshots set KEEPTHEM to any value
# Be sure that you have sufficient storage for this as files are around 5 Kb
# and can add up over time!
KEEPTHEM=yes

###############       Do not edit below this line         ##################
###############    Unless you know what you're doing      ##################

fail() {
	echo "$RUNDATE Modem is unreachable" >> "$LOGPATH/arris_errors.txt"
	exit 1
}

RUNDATE=$(date "+%F %T")
[[ ! -d "$LOGPATH" ]] && echo "You defined an invalid LOGPATH!" && exit 1

# remove old dump file to avoid duplicate entries
[[ -f "$TEMP" ]] && rm -f "$TEMP"

# try to get stats 6 times waiting 10 sec per time
wget -q -T 10 -t 6 http://192.168.100.1/cgi-bin/status_cgi -O $TEMP || fail

if [[ -n "$KEEPTHEM" ]]; then
	SAVE="$LOGPATH/snapshots"
	CAPDATE=$(date -d "$RUNDATE" "+%Y%m%d_%H%M%S")
	[[ ! -d "$SAVE" ]] && mkdir "$SAVE"
	[[ -f "$TEMP" ]] && cp "$TEMP" "$SAVE/$CAPDATE.html"
fi

# find downstream frequencies
DF1=$(grep 'Downstream 1' $TEMP | awk -F'<td>' '{ print $4 }' | sed 's/<.*//')
DF2=$(grep 'Downstream 2' $TEMP | awk -F'<td>' '{ print $13 }' | sed 's/<.*//')
DF3=$(grep 'Downstream 3' $TEMP | awk -F'<td>' '{ print $22 }' | sed 's/<.*//')
DF4=$(grep 'Downstream 4' $TEMP | awk -F'<td>' '{ print $31 }' | sed 's/<.*//')
DF5=$(grep 'Downstream 5' $TEMP | awk -F'<td>' '{ print $40 }' | sed 's/<.*//')
DF6=$(grep 'Downstream 6' $TEMP | awk -F'<td>' '{ print $49 }' | sed 's/<.*//')
DF7=$(grep 'Downstream 7' $TEMP | awk -F'<td>' '{ print $58 }' | sed 's/<.*//')
DF8=$(grep 'Downstream 8' $TEMP | awk -F'<td>' '{ print $67 }' | sed 's/<.*//')

# downstream power
DP1=$(grep "$DF1" $TEMP | awk -F'<td>' '{ print $5 }' | sed 's| dBmV.*||')
DP2=$(grep "$DF2" $TEMP | awk -F'<td>' '{ print $14 }' | sed 's| dBmV.*||')
DP3=$(grep "$DF3" $TEMP | awk -F'<td>' '{ print $23 }' | sed 's| dBmV.*||')
DP4=$(grep "$DF4" $TEMP | awk -F'<td>' '{ print $32 }' | sed 's| dBmV.*||')
DP5=$(grep "$DF5" $TEMP | awk -F'<td>' '{ print $41 }' | sed 's| dBmV.*||')
DP6=$(grep "$DF6" $TEMP | awk -F'<td>' '{ print $50 }' | sed 's| dBmV.*||')
DP7=$(grep "$DF7" $TEMP | awk -F'<td>' '{ print $59 }' | sed 's| dBmV.*||')
DP8=$(grep "$DF8" $TEMP | awk -F'<td>' '{ print $68 }' | sed 's| dBmV.*||')

# downstream snr
DS1=$(grep "$DF1" $TEMP | awk -F'<td>' '{ print $6 }' | sed 's| dB.*||')
DS2=$(grep "$DF2" $TEMP | awk -F'<td>' '{ print $15 }' | sed 's| dB.*||')
DS3=$(grep "$DF3" $TEMP | awk -F'<td>' '{ print $24 }' | sed 's| dB.*||')
DS4=$(grep "$DF4" $TEMP | awk -F'<td>' '{ print $33 }' | sed 's| dB.*||')
DS5=$(grep "$DF5" $TEMP | awk -F'<td>' '{ print $42 }' | sed 's| dB.*||')
DS6=$(grep "$DF6" $TEMP | awk -F'<td>' '{ print $51 }' | sed 's| dB.*||')
DS7=$(grep "$DF7" $TEMP | awk -F'<td>' '{ print $60 }' | sed 's| dB.*||')
DS8=$(grep "$DF8" $TEMP | awk -F'<td>' '{ print $69 }' | sed 's| dB.*||')

# find upstream frequencies
# note my modem does not show a value for Upstream 2
# so use a different strategy

UF1=$(grep '<td>Upstream' $TEMP | awk -F'<td>' '{ print $4 }' | sed 's/<.*//')
UF2=$(grep '<td>Upstream' $TEMP | awk -F'<td>' '{ print $11 }' | sed 's/<.*//')
UF3=$(grep '<td>Upstream' $TEMP | awk -F'<td>' '{ print $18 }' | sed 's/<.*//')

# upstream power
UP1=$(grep "$UF1" $TEMP | awk -F'<td>' '{ print $5 }' | sed 's| dBmV.*||')
UP2=$(grep "$UF2" $TEMP | awk -F'<td>' '{ print $12 }' | sed 's| dBmV.*||')
UP3=$(grep "$UF3" $TEMP | awk -F'<td>' '{ print $19 }' | sed 's| dBmV.*||')

# force a 0 value when undefined due to poor connectivity
[[ "$DF1" = "----</td>" ]] && DF1=0
[[ "$DF2" = "----</td>" ]] && DF2=0
[[ "$DF3" = "----</td>" ]] && DF3=0
[[ "$DF4" = "----</td>" ]] && DF4=0
[[ "$DF5" = "----</td>" ]] && DF5=0
[[ "$DF6" = "----</td>" ]] && DF6=0
[[ "$DF7" = "----</td>" ]] && DF7=0
[[ "$DF8" = "----</td>" ]] && DF8=0
[[ "$DP1" = "----</td>" ]] && DP1=0
[[ "$DP2" = "----</td>" ]] && DP2=0
[[ "$DP3" = "----</td>" ]] && DP3=0
[[ "$DP4" = "----</td>" ]] && DP4=0
[[ "$DP5" = "----</td>" ]] && DP5=0
[[ "$DP6" = "----</td>" ]] && DP6=0
[[ "$DP7" = "----</td>" ]] && DP7=0
[[ "$DP8" = "----</td>" ]] && DP8=0

[[ "$DS1" = "----</td>" ]] && DS1=0
[[ "$DS2" = "----</td>" ]] && DS2=0
[[ "$DS3" = "----</td>" ]] && DS3=0
[[ "$DS4" = "----</td>" ]] && DS4=0
[[ "$DS5" = "----</td>" ]] && DS5=0
[[ "$DS6" = "----</td>" ]] && DS6=0
[[ "$DS7" = "----</td>" ]] && DS7=0
[[ "$DS8" = "----</td>" ]] && DS8=0

[[ "$UF1" = "----</td>" ]] && UF1=0
[[ "$UF2" = "----</td>" ]] && UF2=0
[[ "$UF3" = "----</td>" ]] && UF3=0
[[ -z "$UF1" ]] && UF1=0
[[ -z "$UF2" ]] && UF2=0
[[ -z "$UF3" ]] && UF3=0

[[ "$UP1" = "----</td>" ]] && UP1=0
[[ "$UP2" = "----</td>" ]] && UP2=0
[[ "$UP3" = "----</td>" ]] && UP3=0
[[ -z "$UP1" ]] && UP1=0
[[ -z "$UP2" ]] && UP2=0
[[ -z "$UP3" ]] && UP3=0

# The individual log files
DLOGFREQ="$LOGPATH/downstream-freq.csv"
DLOGPOWER="$LOGPATH/downstream-power.csv"
DLOGSNR="$LOGPATH/downstream-SNR.csv"
ULOGFREQ="$LOGPATH/upstream-freq.csv"
ULOGPOWER="$LOGPATH/upstream-power.csv"

# downstream frequency log
[[ ! -f $DLOGFREQ ]] && echo "DTS,Downstream 1,Downstream 2,Downstream 3,Downstream 4,Downstream 5,Downstream 6,Downstream 7,Downstream 8" > $DLOGFREQ
echo "$RUNDATE,${DF1/ *},${DF2/ *},${DF3/ *},${DF4/ *},${DF5/ *},${DF6/ *},${DF7/ *},${DF8/ *}" >> $DLOGFREQ

# downstream power log
[[ ! -f $DLOGPOWER ]] && echo "DTS,Downstream 1,Downstream 2,Downstream 3,Downstream 4,Downstream 5,Downstream 6,Downstream 7,Downstream 8" > $DLOGPOWER
echo "$RUNDATE,$DP1,$DP2,$DP3,$DP4,$DP5,$DP6,$DP7,$DP8" >> $DLOGPOWER

# downstream SNR log
[[ ! -f $DLOGSNR ]] && echo "DTS,Downstream 1,Downstream 2,Downstream 3,Downstream 4,Downstream 5,Downstream 6,Downstream 7,Downstream 8" > $DLOGSNR
echo "$RUNDATE,$DS1,$DS2,$DS3,$DS4,$DS5,$DS6,$DS7,$DS8" >> $DLOGSNR

# upstream freq log
[[ ! -f $ULOGFREQ ]] && echo "DTS,Upstream 1,Upstream 2,Upstream 3" > $ULOGFREQ
echo "$RUNDATE,${UF1/ *},${UF2/ *},${UF3/ *}" >> $ULOGFREQ

# upstream power log
[[ ! -f $ULOGPOWER ]] && echo "DTS,Upstream 1,Upstream 2,Upstream 3" > $ULOGPOWER
echo "$RUNDATE,$UP1,$UP2,$UP3" >> $ULOGPOWER
