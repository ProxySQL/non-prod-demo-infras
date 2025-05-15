#!/bin/sh

echo "Delete root qdisc"
sudo tc qdisc del dev lo root
echo "Substitute 'pfifo_fast' qdisc with 'prio' - ALL traffic to band 1:3"
sudo tc qdisc add dev lo root handle 1: prio priomap 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
echo "Add delay to band 1:1"
sudo tc qdisc add dev lo parent 1:1 handle 10: netem delay 50ms 30ms distribution normal
echo "Redirect traffict to band with no limit (DROP) 1:2 to 1:1"
sudo tc qdisc add dev lo parent 1:2 handle 20: netem limit 0

# IP Range
START_IP=1
END_IP=255
BASE_IP="10.200.1"  # Base IP address

# Loop through the specified range
for N in $(seq $START_IP $END_IP); do
	# Add iptables rule to forward traffic
	echo "Add traffic filter   IP="$BASE_IP.$N""
	sudo tc filter add dev lo parent 1:0 prio 1 protocol ip handle $N fw flowid 1:1
done
