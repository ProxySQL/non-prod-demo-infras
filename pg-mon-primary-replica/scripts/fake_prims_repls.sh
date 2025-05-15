#!/bin/bash

# IP Range
START_IP=1
END_IP=10
BASE_IP="10.200.1"
PORT=5432

# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
	key="$1"
	case "$key" in
		# Base IP range from which to start
		-b|--base)
			shift
			BASE_IP="$1"
		;;
		# IP number in which to finish the range
		-e|--end)
			shift
			END_IP="$1"
		;;
		# The primary port to be used. Replica will be 'primary + 1'
		-p|--pport)
			shift
			PORT="$1"
		;;
		*)
		# Exit with error for 'unknown'
			echo "Unknown option '$key'"
			exit 1
		;;
	esac
	shift
done

echo "Remove ALL current 'nat' rules"
sudo iptables -t nat -L OUTPUT --line-numbers -v -n |\
	grep 'DNAT' | awk '{print $1}' | tac |\
	while read -r line; do
		echo "Removing rule $line"
		sudo iptables -t nat -D OUTPUT "$line";
	done

# Loop through the specified range
for N in $(seq $START_IP $END_IP); do
	IP="$BASE_IP.$N"

	if [[ $(($N % 2)) == 0 ]]; then
		MPORT="1$(($PORT+1))"
	else
		MPORT="1$PORT"
	fi

	echo "Adding forwarding iptables rule   DPORT="$PORT" IP="$IP" MPORT="$MPORT

	sudo iptables -t nat -A OUTPUT -d $IP -p tcp --dport $PORT -j DNAT --to-destination 127.0.0.1:$MPORT
	sudo iptables -t mangle -A OUTPUT -d $IP -j MARK --set-mark $N
done

echo "iptables rules created for IPs from $BASE_IP.$START_IP to $BASE_IP.$END_IP"
