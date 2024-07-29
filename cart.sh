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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOG_FILE
validate $? " downloading cart zip "

cd /app
validate $? " changing dir to /app "

unzip -o /tmp/cart.zip &>> $LOG_FILE
validate $? " unzip cart zip flie "

if [ $(pwd) == "/app" ]
then
npm install &>> $LOG_FILE
validate $? " configuring npm "
else
exit 1
fi

cp /home/centos/shell_script/cart.service /etc/systemd/system/cart.service
validate $? " copy cart service file "

systemctl daemon-reload &>> $LOG_FILE
validate $? " cart deamon relaod "

systemctl enable cart &>> $LOG_FILE
validate $? " enable cart service "

systemctl start cart &>> $LOG_FILE
validate $? " starting cart service "
