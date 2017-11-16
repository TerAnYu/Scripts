#!/bin/sh
. $(dirname $0)/change_dc_conf.sh

# https://devidiom.blog/2015/12/03/simple-bash-server-check-script/
if `nc -z -w 5 "${contr1}" "${CPORT}"` ; then
    eths=${contr1}
    echo success dc1
elif `nc -z -w 5 "${contr2}" "${CPORT}"`; then
    eths=${contr2}
    echo success dc2
elif `nc -z -w 5 "${contr3}" "${CPORT}"`; then
    eths=${contr3}
    echo success dc3
elif `nc -z -w 5 "${contr4}" "${CPORT}"`; then
    eths=${contr4}
    echo success dc4
else
    echo "Всё пропало! Все контроллеры недоступны!"
    rm -f /tmp/*.lpta
fi


# Создаём файл при переключении и если этот файл соответствует установленному адресу, то ничего не делаем, иначе переключаем на новый адрес и блокируем его
if [ -f "/tmp/${eths}.lpta" ]; then
#    echo "Адрес ${eths} уже указан"
    echo
else
    rm -f /tmp/*.lpta
    echo "Указываем адрес ${eths}"
    iptables -t nat -v -L OUTPUT -n --line-number | grep -w localpottoaddress | grep -w tcp | awk '{system ("iptables -t nat -D OUTPUT " $1)}'
    iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p tcp -m multiport --dport ${PORTSS} -j DNAT --to-destination ${eths} -m comment --comment "localpottoaddress"
sleep 2
    iptables -t nat -v -L OUTPUT -n --line-number | grep -w localpottoaddress | grep -w udp | awk '{system ("iptables -t nat -D OUTPUT " $1)}'
    iptables -t nat -A OUTPUT -m addrtype --src-type LOCAL --dst-type LOCAL -p udp -m multiport --dport ${PORTSS} -j DNAT --to-destination ${eths} -m comment --comment "localpottoaddress"

    touch /tmp/${eths}.lpta
fi

# Проверяем на наличие маскарада, если есть, то ничего не делаем, если нет, удаляем если есть и прописываем снова
if [ -n "`iptables -t nat -v -L POSTROUTING -n --line-number | grep -w localporttoaddress`" ]
then
    echo
else
    rm -f /tmp/*.lpta
# https://serverfault.com/questions/247623/iptables-redirect-local-connections-to-remote-system-port
# (which works only in kernels >= 3.6)
# https://superuser.com/questions/661772/iptables-redirect-to-localhost
    sysctl -w net.ipv4.conf.all.route_localnet=1
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -v -L POSTROUTING -n --line-number | grep -w localporttoaddress | awk '{system ("iptables -t nat -D POSTROUTING " $1)}'
    iptables -t nat -A POSTROUTING -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE -m comment --comment "localporttoaddress"
fi

exit 0
