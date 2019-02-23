#!/usr/bin/env bash
#
# Description: Unixbench script
# Author: Biubibi
# Thanks: unixbench.sh <i@teddysun>
# Intro: http://www.webhk.top/posts/d7ee8401.html

cur_dir=/opt/unixbench
UnixBench_file="UnixBench-5.1.4.tar.gz"
UnixBench_url="https://github.com/qcsuper/byte-unixbench/releases/download/v5.1.4/UnixBench-5.1.4.tar.gz"

# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

# check os
if [ -f /etc/redhat-release ]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
fi

# Install necessary libaries
if [ "$release" == 'centos' ]; then
    yum -y update
    yum -y install make automake gcc autoconf gcc-c++ time perl-Time-HiRes
else
    apt-get -y update
    apt-get -y install make automake gcc autoconf time perl
fi

# Create new dir
mkdir -p ${cur_dir}
cd ${cur_dir}

# Download UnixBench5.1.4
if [ -s ${UnixBench_file} ]; then
    echo "UnixBench5.1.4.tgz [found]"
else
    echo "UnixBench5.1.4.tgz not found!!!download now..."
    if ! wget -c ${UnixBench_url}; then
        echo "Failed to download UnixBench5.1.4.tgz, please download it to ${cur_dir} directory manually and try again."
        exit 1
    fi
fi
tar -zxvf ${UnixBench_file} && rm -f ${UnixBench_file}
cd UnixBench/

# Run unixbench
make
./Run

echo
echo
echo "======= Script description and score comparison completed! ======= "
echo
echo

