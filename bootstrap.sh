#! /bin/bash

sudo apt-get update
sudo apt-get upgrade

sudo pip install -U \
    typing \
    boto3 \
    scipy \
    pandas \
    scikit-learn