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

 dnf install golang -y  &>> $LOG_FILE
 validate "$?" "Installing golang"

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

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOG_FILE
validate $? " Downloading dispatch  "

cd /app &>> $LOG_FILE
validate $? " changing dir to /app "

unzip -o /tmp/dispatch.zip &>> $LOG_FILE
validate $? " unzip dispatch zip flie "

if [ $(pwd) == "/app" ]
then
go mod init dispatch &>> $LOG_FILE
validate $? " go mod init "
go get &>> $LOG_FILE
validate $? " go get "
go build  &>> $LOG_FILE
validate $? " go build "
else
exit 1
fi

cp /home/centos/shell_script/dispatch.service /etc/systemd/system/dispatch.service &>> $LOG_FILE
validate $? " copying dispatch service file "

systemctl daemon-reload &>> $LOG_FILE
validate $? " Deamon relaod "

systemctl enable dispatch &>> $LOG_FILE
validate $? " enable dispatch service "

systemctl start dispatch &>> $LOG_FILE
validate $? " starting dispatch service "
