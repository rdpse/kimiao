#!/bin/bash

export PATH=$HOME/phantomjs/bin:$PATH

RBFILE=$HOME/kimiao.rb
PJS_VERSION=1.9.8

if [ -f $RBFILE ]; then
  screen -S kimiao sh -c 'ruby '$RBFILE''
  exit 0
fi

deps='ruby ruby-dev screen build-essential bison openssl
  libreadline6 libreadline6-dev curl zlib1g zlib1g-dev 
  libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev 
  automake libtool libfontconfig1-dev'

depsrhel='ruby ruby-devel screen patch gcc-c++ kernel-devel 
  bison openssl-devel readline-devel curl zlib-devel 
  libyaml-devel libxml2-devel autoconf glibc-devel ncurses-devel 
  automake libtool libfontconfig1-dev'

if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    sudo apt-get -y install $deps
elif [ -f /etc/redhat-release ]; then
    sudo yum -y install $depsrhel
fi

cd $HOME
wget -O- https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PJS_VERSION-linux-x86_64.tar.bz2 | tar xj
mv phantomjs-$PJS_VERSION-linux-x86_64 phantomjs

wget https://raw.githubusercontent.com/rdpse/kimiao/master/kimiao.rb
sudo gem install capybara poltergeist
chmod +x $RBFILE
screen -S kimiao sh -c 'ruby '$RBFILE''
