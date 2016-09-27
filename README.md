## What is it and why?
This very trivial script will log the downstream/upstream power levels as well as the SNR from your Arris TM822 and related modem to individual csv values suitable for graphing in [dygraphs](http://github.com/danvk/dygraphs).

Use it to monitor powerlevels and SNR values over time to aid in troubleshooting connectivity with your ISP. The script is easily called from a cronjob at some appropriate interval (hourly for example). It is recommended that users simply call the script via a cronjob at the disired interval. Perhaps twice per hour is enough resolution.

## Installation and Usage
* Place the script 'arris-capture.sh' in a directory of your choosing and make it executable.
* Edit the first section of the script to defining the path for storage of the log files.
* Note that this path needs to be web-exposed for dygraph to work properly.
* Place 'dygraph-combined.js' and 'index.html' into the web-exposed dir you defined above.
* Setup a cronjob to run the script at some interval.

Note that I assume you have a running http server properly configured.

## Example
![downstream](http://s19.postimg.org/ipxbyyr8z/downstream.png)
![upstream](http://s19.postimg.org/7euoalkdv/upstream.png)

## Notes
Note that the crude grep/awk/sed lines work fine on an Arris TM822G running
* Firmware            : TS0901103M2D_060616_MODEL_7_8_PC20_CT
* Firmware build time : Mon Jun 6 21:53:07 EDT 2016
