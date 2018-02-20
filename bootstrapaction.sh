#!/usr/bin/env bash
# Commands to install anaconda python
# Python packages

sudo yum -y update
#              Install Anaconda (Python 3) & Set To Default              
wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh -O ~/anaconda.sh

bash ~/anaconda.sh -b -p $HOME/anaconda

echo -e '\nexport PATH=$HOME/anaconda/bin:$PATH' >> $HOME/.bashrc && source $HOME/.bashrc

#                    Install Additional Packages              
conda install -y psycopg2

# Run only master node

if grep isMaster /mnt/var/lib/info/instance.json | grep true;
then
    aws s3 cp s3://<s3-bucket>/zepplin-setup/resources/ zeppelinsetup --recursive
    sudo cp ./zeppelinsetup/shiro.ini /usr/lib/zeppelin/conf/shiro.ini
    sudo cp ./zeppelinsetup/zeppelin-env.sh /usr/lib/zeppelin/conf/zeppelin-env.sh
    sudo cp ./zeppelinsetup/zeppelin-site.xml /usr/lib/zeppelin/conf/zeppelin-site.xml
    sudo cp ./zeppelinsetup/interpreter.json /usr/lib/zeppelin/conf/interpreter.json
    sudo stop zeppelin && sudo start zeppelin
    echo " completed zeppelin setup"
else 
    echo " zeppelin setup is only done on master node"
    exit 0;
fi