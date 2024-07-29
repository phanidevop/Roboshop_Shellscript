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

 dnf install python36 gcc python3-devel -y &>> $LOG_FILE
 validate "$?" "Install Python 3.6"

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then
useradd roboshop &>> $LOG_FILE
validate $? " $G adding robo user $N "
else
echo -e " $Y roboshop user already exits $N "
fi

mkdir -p /app &>> $LOG_FILE
validate $? " creating /app dir "

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOG_FILE
validate $? " Downloading payment  "

cd /app &>> $LOG_FILE
validate $? " changing dir to /app "

unzip -o /tmp/payment.zip &>> $LOG_FILE
validate $? " unzip payment zip flie "

if [ $(pwd) == "/app" ]
then
pip3.6 install -r requirements.txt &>> $LOG_FILE
validate $? " Installing dependencies "
else
exit 1
fi

cp /home/centos/shell_script/payment.service /etc/systemd/system/payment.service &>> $LOG_FILE
validate $? " copying payment service file "

systemctl daemon-reload &>> $LOG_FILE
validate $? " Deamon relaod "

systemctl enable payment &>> $LOG_FILE
validate $? " enable payment service "

systemctl start payment &>> $LOG_FILE
validate $? " starting payment service "
