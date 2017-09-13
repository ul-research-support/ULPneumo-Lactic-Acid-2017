#!/bin/bash

#apt-get update -y
##sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
#gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
#gpg -a --export E084DAB9 | sudo apt-key add -
#apt-get update -y
apt-get install -y r-base
sudo su - -c "R -e \"install.packages('tableone', repos='http://cran.rstudio.com/')\""
sudo sh -c 'echo "cd /vagrant\nR" >> /home/vagrant/.bashrc'
sudo sh -c 'echo ".First <- function(){library(utils)\nlibrary(stats)\nsource(\"/vagrant/script.R\")}" >> /usr/lib/R/etc/Rprofile.site'
