#!/bin/bash

iptables -D INPUT -p udp -m udp --dport $SERVERPORT -j ACCEPT
iptables -D INPUT -i wg0 -j wg0-input

iptables -F wg0-input
iptables -F wg0-input-iscsi
