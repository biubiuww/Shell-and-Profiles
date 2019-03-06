#!/usr/bin/env bash
# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

# check os
var=`lsb_release -a | grep Gentoo`
if [ -z "${var}" ]; then
	var=`cat /etc/issue | grep Gentoo`
fi

if [ -d "/etc/runlevels/default" -a -n "${var}" ]; then
	LINUX_RELEASE="GENTOO"
else
	LINUX_RELEASE="OTHER"
fi

# stop aegis and aliyundun service
stop_service(){
    killall -9 aegis_cli >/dev/null 2>&1
    killall -9 aegis_update >/dev/null 2>&1
    killall -9 aegis_cli >/dev/null 2>&1
    killall -9 aegis_quartz >/dev/null 2>&1
    killall -9 AliYunDun >/dev/null 2>&1
    killall -9 AliHids >/dev/null 2>&1
    killall -9 AliYunDunUpdate >/dev/null 2>&1
    printf "%-40s %40s\n" "Stopping aegis" "[  OK  ]"
    printf "%-40s %40s\n" "Stopping quartz" "[  OK  ]"
}

# remove aegis and aliyundun
remove_aliyundun(){
if [ -d /usr/local/aegis ];then
    rm -rf /usr/local/aegis/aegis_client
    rm -rf /usr/local/aegis/aegis_update
    rm -rf /usr/local/aegis/aegis_quartz
    rm -rf /usr/local/aegis/alihids
fi
}

# uninstall all service
uninstall_service() {
   if [ -f "/etc/init.d/aegis" ]; then
        /etc/init.d/aegis stop  >/dev/null 2>&1
        rm -f /etc/init.d/aegis
   fi

	if [ $LINUX_RELEASE = "GENTOO" ]; then
		rc-update del aegis default 2>/dev/null
		if [ -f "/etc/runlevels/default/aegis" ]; then
			rm -f "/etc/runlevels/default/aegis" >/dev/null 2>&1;
		fi
    elif [ -f /etc/init.d/aegis ]; then
         /etc/init.d/aegis  uninstall
	    for ((var=2; var<=5; var++)) do
			if [ -d "/etc/rc${var}.d/" ];then
				 rm -f "/etc/rc${var}.d/S80aegis"
		    elif [ -d "/etc/rc.d/rc${var}.d" ];then
				rm -f "/etc/rc.d/rc${var}.d/S80aegis"
			fi
		done
    fi
}

# clear residual file
remove_residual(){
    pkill aliyun-service
    rm -fr /etc/init.d/agentwatch /usr/sbin/aliyun-service
    rm -rf /usr/local/aegis*
    printf "%-40s %40s\n" "Remove residual file" "[  OK  ]"
}

# add ip blacklist
iptables_list(){
    iptables -I INPUT -s 140.205.201.0/28 -j DROP
    iptables -I INPUT -s 140.205.201.16/29 -j DROP
    iptables -I INPUT -s 140.205.201.32/28 -j DROP
    iptables -I INPUT -s 140.205.225.192/29 -j DROP
    iptables -I INPUT -s 140.205.225.200/30 -j DROP
    iptables -I INPUT -s 140.205.225.184/29 -j DROP
    iptables -I INPUT -s 140.205.225.183/32 -j DROP
    iptables -I INPUT -s 140.205.225.206/32 -j DROP
    iptables -I INPUT -s 140.205.225.205/32 -j DROP
    iptables -I INPUT -s 140.205.225.195/32 -j DROP
    iptables -I INPUT -s 140.205.225.204/32 -j DROP
    iptables -I INPUT -s 140.205.201.0/28 -j DROP
    iptables -I INPUT -s 140.205.201.16/29 -j DROP
    iptables -I INPUT -s 140.205.201.32/28 -j DROP
    iptables -I INPUT -s 140.205.225.192/29 -j DROP
    iptables -I INPUT -s 140.205.225.200/30 -j DROP
    iptables -I INPUT -s 140.205.225.184/29 -j DROP
    iptables -I INPUT -s 140.205.225.183/32 -j DROP
    iptables -I INPUT -s 140.205.225.206/32 -j DROP
    iptables -I INPUT -s 140.205.225.205/32 -j DROP
    iptables -I INPUT -s 140.205.225.195/32 -j DROP
    iptables -I INPUT -s 140.205.225.204/32 -j DROP
    iptables -I INPUT -s 106.11.224.0/26 -j DROP
    iptables -I INPUT -s 106.11.224.64/26 -j DROP
    iptables -I INPUT -s 106.11.224.128/26 -j DROP
    iptables -I INPUT -s 106.11.224.192/26 -j DROP
    iptables -I INPUT -s 106.11.222.64/26 -j DROP
    iptables -I INPUT -s 106.11.222.128/26 -j DROP
    iptables -I INPUT -s 106.11.222.192/26 -j DROP
    iptables -I INPUT -s 106.11.223.0/26 -j DROP
    /etc/init.d/iptables save
    /etc/init.d/iptables restart
     printf "%-40s %40s\n" "AliYunDun IP add blacklist" "[  OK  ]"
}

stop_service
remove_aliyundun
uninstall_service
remove_residual
iptables_list

umount /usr/local/aegis/aegis_debug
printf "%-40s %40s\n" "Uninstalling AliYunDun"  "[  OK  ]"