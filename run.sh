#!/bin/bash

PJS_VERSION=1.9.8
declare -a deps=('ruby' 'screen' 'git')

if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    apt-get -y install ${deps[@]}
elif [ -f /etc/redhat-release ]; then
    yum -y install ${deps[@]}
fi

cd ~
wget -O- https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PJS_VERSION-linux-x86_64.tar.bz2 | tar xj
mv phantomjs-$PJS_VERSION-linux-x86_64 phantomjs
ln -s phantomjs/bin/phantomjs /usr/local/sbin/phantomjs

git clone https://github.com/rdpse/kimiao.git .
screen -S kimiao ./kimiao.rb





