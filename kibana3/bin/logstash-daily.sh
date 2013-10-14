#!/bin/sh
 
# Do elasticsearch optimize on logstash previous day index
# if $1 = all then optimize all indicies

escluster="`grep cluster /etc/logstash/logstash-elasticsearch.conf |sed -e 's/.*"\(.*\)".*/\1/g'`"
esindex="/var/lib/elasticsearch/${escluster}/nodes/0/indices"
# Grab yesterday's values
D=`date +%d -d yesterday`
M=`date +%m -d yesterday`
Y=`date +%Y -d yesterday`
today="`date +%Y`.`date +%m`.`date +%d`"
yesterday="$Y.$M.$D"
 
# If $1 = all
if [ "x$1" = "xall" ]
then
    # Loop through all ES indicies except today
    for index in `ls $esindex | grep -v "$today"`
    do
        # Run through all the indicies and optimize them
        echo "Optimizing $index"
        curl -XPOST "http://localhost:9200/$index/_optimize?max_num_segments=2"
    done
else
    if [ -d "$esindex/logstash-$yesterday" ];then
      echo "Optimizing index logstash-$yesterday"
      curl -XPOST "http://localhost:9200/logstash-$yesterday/_optimize?max_num_segments=2"
    else 
      echo "No index exists for logstash-${yesterday}"
    fi
fi
