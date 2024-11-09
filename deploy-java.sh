#!/bin/bash
declare -i badpa_java
badpa_java=$(ps aux | grep "/usr/lib/jvm/jdk-17-oracle-x64/bin/java -jar /srv/back/shipment/bin/Barbanet.jar" | grep -v grep | awk '{print $2}')
if [ "$badpa_java" -gt 0 ]; then
        echo "the java pid is $badpa_java"
        kill -9 $badpa_java
        sleep 5
        if [ $? -eq 0 ]; then
                echo "going to start badpa.sh"
                bash /srv/back/shipment/badpa.sh > /dev/null   
                if [ $? -eq 0 ];then
                        declare -i badpa_java2
                        badpa_java2=$(ps aux | grep "/usr/lib/jvm/jdk-17-oracle-x64/bin/java -jar /srv/back/shipment/bin/Barbanet.jar" | grep -v grep | awk '{print $2}')
                        echo "app started with pid $badpa_java2"
        else
                echo "an error occurred during killing the process!!"
                fi
        fi

else 
        echo "there is no java app running on server"
        bash /srv/back/shipment/badpa.sh > /dev/null
        if [ $? -eq 0 ] ;then
        declare -i badpa_java1
        badpa_java1=$(ps aux | grep "/usr/lib/jvm/jdk-17-oracle-x64/bin/java -jar /srv/back/shipment/bin/Barbanet.jar" | grep -v grep | awk '{print $2}')
        echo "application is going to start with pid $badpa_java1"
        fi
fi

echo -e "\n------------# testing new deployment... #-----------"
declare -i counter success
counter=0
success=0
while [ $counter -lt 180 ];do
curl -m 2 -s -I localhost:8080/api/v1/pub/system/status | grep 200
if [ $? -eq 0 ]
then
        success=1
        echo -e "\n------------# new deployment passed! #-----------"
        break
else
        sleep 2
        counter=$counter+1
fi
done
if [ $success -eq 1 ]
then
        exit 0
else
        echo -e "\n------------# new deployment has failed! #-----------"
        exit 1
fi
