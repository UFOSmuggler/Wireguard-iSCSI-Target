#!/bin/bash

iptables -I INPUT -p udp --dport $SERVERPORT -j ACCEPT

iptables -N wg0-input
iptables -N wg0-input-iscsi

iptables -I INPUT -i wg0 -j wg0-input
iptables -A wg0-input -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A wg0-input -p tcp --dport 3260 -j wg0-input-iscsi
iptables -A wg0-input -j REJECT

iptables -A wg0-input-iscsi -s 172.16.222.2 -j ACCEPT
