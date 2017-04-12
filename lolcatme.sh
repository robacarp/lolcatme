#! /usr/bin/env bash

mkdir ~/lolcatme
cd ~/lolcatme
brew install lolcat &
curl -fsSL 'https://raw.githubusercontent.com/robacarp/lolcatme/master/lolcatme.rb?token=AAMvB1hJekKlwMPqddCdxyIpD1ne41n0ks5Y96StwA%3D%3D' > lolcatme.rb
