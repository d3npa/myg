a WEP-protected wi-fi network for the nds.
assumes nftables.

partly claude coded (opus 4.6). i ran through it and tweaked by hand.

./ds-wifi.sh start
./ds-wifi.sh stop

'stop' should clean up all the nftables it set up; works on my machine (tm)


