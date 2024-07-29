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

 dnf install nginx -y &>> $LOG_FILE
validate $? " Install ngnix "

 systemctl enable nginx &>> $LOG_FILE
validate $? " enable ngnix "

 systemctl start nginx &>> $LOG_FILE
validate $? " start ngnix "

 rm -rf /usr/share/nginx/html/*  &>> $LOG_FILE
validate $? " Delete default ngnix html file "

 curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip  &>> $LOG_FILE
validate $? " Downloading web application "

 cd /usr/share/nginx/html  &>> $LOG_FILE
 validate $? " changing to ngnix home direcctory "

 unzip /tmp/web.zip  &>> $LOG_FILE
validate $? " unzipiing web "

 cp /home/centos/shell_script/roboshop.conf /etc/nginx/default.d/roboshop.conf   &>> $LOG_FILE
validate $? " copied roboshop reverse proxy config "

systemctl restart nginx &>> $LOG_FILE
validate $? " restart  nginx"