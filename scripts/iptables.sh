#!/bin/bash

ipt=/sbin/iptables
ssh_port=10020
rtmp_port=1935
http_port=80
kibana_port=8000


lan=10.10.10.0/24



$ipt -F
$ipt -t nat -F

$ipt -A INPUT -s 127.0.0.1 -j ACCEPT

##wan###
$ipt -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
$ipt -A INPUT -p tcp -m multiport --dport $kibana_port,$http_port,$rtmp_port,$ssh_port -m state --state NEW -j ACCEPT

###wan###



###lan###
$ipt -A INPUT -s $lan -j ACCEPT

###lan###


$ipt -A INPUT -j DROP