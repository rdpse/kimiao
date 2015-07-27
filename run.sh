#!/bin/bash

HOMEDIR=$(echo $HOME)
PJS_VERSION=1.9.8

if [ -d $HOMEDIR/kimiao ]; then
  export PATH=$HOMEDIR/phantomjs/bin:$PATH
  screen -S kimiao sh -c 'ruby '$HOMEDIR'/kimiao/kimiao.rb'
  exit 0
fi

declare -a deps=('ruby' 'ruby-dev' 'screen' 'git' 'build-essential' 'bison' 'openssl'
  'libreadline6' 'libreadline6-dev' 'curl' 'git-core' 'zlib1g' 'zlib1g-dev'
  'libssl-dev' 'libyaml-dev' 'libxml2-dev' 'autoconf' 'libc6-dev' 'ncurses-dev'
  'automake' 'libtool' 'libfontconfig1-dev')

declare -a depsrhel=('ruby' 'ruby-devel' 'screen' 'git' 'gcc-c++' 'kernel-devel' 'bison' 'openssl-devel'
  'readline-devel' 'curl' 'git-core' 'zlib-devel'
  'libyaml-devel' 'libxml2-devel' 'autoconf' 'glibc-devel' 'ncurses-devel'
  'automake' 'libtool' 'libfontconfig1-dev')

if [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    sudo apt-get -y install ${deps[@]}
elif [ -f /etc/redhat-release ]; then
    sudo yum -y install ${depsrhel[@]}
fi

cd $HOMEDIR
wget -O- https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PJS_VERSION-linux-x86_64.tar.bz2 | tar xj
mv phantomjs-$PJS_VERSION-linux-x86_64 phantomjs
export PATH=$HOMEDIR/phantomjs/bin:$PATH

git clone https://github.com/rdpse/kimiao.git
cd $HOMEDIR/kimiao/
  sudo gem install capybara poltergeist
  chmod +x kimiao.rb
  screen -S kimiao sh -c 'ruby kimiao.rb'
