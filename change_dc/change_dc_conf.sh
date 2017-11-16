#!/bin/bash

set PATH=/usr/sbin:/sbin:/usr/bin:/bin

# необходимо установить в rl.local > sleep 120s && /bin/sh /etc/change_dc.sh
# Задаём порты для локального назначения с удалённого адреса
#PORTS="389 636 3268 3269 88 9389 464"
PORTSS="389,636,3268,3269,88,9389,464"
CPORT="389"
comment="localporttoaddress"
biniptables=/sbin/iptables
binsysctl=/sbin/sysctl

# Destinations
contr1="10.150.100.10"
contr2="10.150.100.11"
contr3="10.150.102.10"
contr4="10.150.102.11"
eths=""
