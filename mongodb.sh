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
 if [ $1 == 0 ]; then
         echo -e "$2.. $G  successful $N"
 else
         echo -e "$2.. $R  failed $N"
 fi
}

if [ $ID == 0 ]; then
  echo "Script executed as root user"
else
  echo -e "$R You are not a root user $N, Please run script as root user "
  exit 1;
fi


cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
validate $? "mongodb repo copied"
dnf install mongodb-org -y &>> $LOG_FILE
validate $? "mongodb package installed"
systemctl enable mongod &>> $LOG_FILE
validate $? "mongodb enabled"
systemctl start mongod &>> $LOG_FILE
validate $? "starting mongodb"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
validate $? "values changed to 0.0.0.0"
systemctl restart mongod &>> $LOG_FILE
validate $? "mongodb restarted"