#! /usr/bin/env bash

set -e

image="jasonish/suricata:7.0.2"
pcap="ssh-up-to-client-banner.pcap"

for rules in *.rules; do
    rm -rf ./log
    mkdir log
    echo "===> ${rules}"
    podman run --rm -it \
	   -v "$(pwd):/work" \
	   -w /work \
	   ${image} -S "${rules}" -r "${pcap}" -l ./log
    alert_count=$(cat log/eve.json | jq -c 'select(.alert.signature_id == 1)' | wc -l)
    if [[ "${alert_count}" != 1 ]]; then
	echo "error: expected 1 alert, got ${alert_count}"
	exit 1
    fi
done
