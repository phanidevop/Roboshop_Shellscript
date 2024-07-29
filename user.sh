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

dnf module disable nodejs -y &>> $LOG_FILE
validate $? " disable nodejs "
dnf module enable nodejs:18 -y &>> $LOG_FILE
validate $? " enable nodejs:18 "
dnf install nodejs -y &>> $LOG_FILE
validate $? " install nodejs:18 "
id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]
then
useradd roboshop &>> $LOG_FILE
validate $? " $G adding robo user $N "
else
 echo -e " $Y user already exits $N "
 fi
mkdir -p /app
validate $? " creating /app dir "
curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOG_FILE
validate $? " downloading user zip "
cd /app
validate $? " changing dir to /app "
unzip -o /tmp/user.zip &>> $LOG_FILE
validate $? " unzip user zip flie "
if [ $(pwd) == "/app" ]
then
npm install &>> $LOG_FILE
validate $? "  configuring npm "
else
exit 1
fi
cp /home/centos/shell_script/user.service /etc/systemd/system/user.service
validate $? " copy user service file "

systemctl daemon-reload &>> $LOG_FILE
validate $? " user deamon relaod "

systemctl enable user &>> $LOG_FILE
validate $? " enable user service "

systemctl start user &>> $LOG_FILE
validate $? " starting user service " 

cp /home/centos/shell_script/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
validate $? " copying mongo repo "

dnf install mongodb-org-shell -y  &>> $LOG_FILE
validate $? " install mongo db shell "

mongo --host mongodb.devops1234.online </app/schema/user.js  &>> $LOG_FILE
validate $? "Loading schema"