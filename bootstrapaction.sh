#!/usr/bin/env bash
# Python packages

sudo yum -y update

#                    Install Additional Packages            
wget https://jdbc.postgresql.org/download/postgresql-42.2.2.jar
# copy postgresql jar to /usr/lib/spark/jars/
sudo cp postgresql-42.2.2.jar  /usr/lib/spark/jars/

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
