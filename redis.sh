#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


DATE=$(date +%F)
ID=$(id -u)
LOG_FILE="/tmp/$0-$DATE.log"

echo "Scriptname is $0, script executed on $(date +%F-%Hh:%Mm:%Ss)" &>> $LOG_FILE


validate(){
    if [ $1 == 0 ]
     then
      echo -e " $2... $G sucessfull $N "
     else
      echo -e " $2... $R failure $N "
    fi
}
 
 if [ $ID == 0 ]
  then
   echo -e " $G script $0 excuted as root user "
  else
   echo -e " $R you are not root user $N :: plz run this script with root access "
   exit 1
 fi

 dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOG_FILE
 validate $? "Installing Remi release"

 dnf module enable redis:remi-6.2 -y &>> $LOG_FILE
 validate $? "enabling redis"

 dnf install redis -y &>> $LOG_FILE
 validate $? "Installing Redis"

 sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOG_FILE
 validate $? "allowing remote connections"

 systemctl enable redis &>> $LOG_FILE
 validate $? "Enabled Redis"

 systemctl start redis &>> $LOG_FILE
 validate $? "Start Redis"