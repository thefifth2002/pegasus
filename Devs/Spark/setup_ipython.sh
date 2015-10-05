#!/bin/bash

sudo apt-get update

sudo apt-get --yes --force-yes install python-dev python-pip git
sudo pip install "ipython[notebook]"

git clone https://github.com/aouyang1/spark_examples.git

echo -e "\nexport AWS_ACCESS_KEY_ID=$1" | cat >> ~/.profile
echo -e "\nexport AWS_SECRET_ACCESS_KEY=$2" | cat >> ~/.profile
. ~/.profile

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
EXECMEM=$(echo "0.90 * ($TOTMEM - 1000)" | bc -l)

tmux new-session -s ipython_notebook -n bash -d

tmux send-keys -t ipython_notebook 'PYSPARK_DRIVER_PYTHON=ipython PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser --port=7777" pyspark --packages com.databricks:spark-csv_2.10:1.1.0 --master spark://'$(hostname)':7077 --executor-memory '${EXECMEM%.*}'M --driver-memory '${EXECMEM%.*}'M' C-m
