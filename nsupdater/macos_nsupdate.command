#!/bin/sh

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

echo "Please enter pcname (macbook-** or macpc-****)"
read userdata
hostname $userdata

# en0 = ethernet - en1 = airport - choose the right interface !
IPADDR=`/sbin/ifconfig en0 | grep 'inet ' | awk '{print $2}'`
HOSTNAME=`hostname -f`

# Optionally set the name server (if not present, it uses system default).
#echo server "${DNSSERVER}" > $TMPDIR/nsupdate

# Change > to >> if name server set.
echo update delete "${HOSTNAME}" A > $TMPDIR/nsupdate
echo update add "${HOSTNAME}" 86400 A "${IPADDR}" >> $TMPDIR/nsupdate
echo show >> $TMPDIR/nsupdate
echo send >> $TMPDIR/nsupdate

nsupdate $TMPDIR/nsupdate
