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

dnf install maven -y  &>> $LOG_FILE
validate "$?" "Installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG_FILE
validate $? " Downloading shipping "

cd /app &>> $LOG_FILE
validate $? " changing dir to /app "

unzip -o /tmp/shipping.zip &>> $LOG_FILE
validate $? " unzip shipping zip flie "

if [ $(pwd) == "/app" ]
then
mvn clean package &>> $LOG_FILE
validate $? " Installing dependencies "
mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
validate $? "renaming jar file"
else
exit 1
fi

cp /home/centos/shell_script/shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE
validate $? " copy shipping service file "

systemctl daemon-reload &>> $LOG_FILE
validate $? " Deamon relaod "

systemctl enable shipping &>> $LOG_FILE
validate $? " enable shipping service "

systemctl start shipping &>> $LOG_FILE
validate $? " starting shipping service "

dnf install mysql -y &>> $LOG_FILE
validate $? "install MySQL client"

mysql -h mysql.devops1234.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOG_FILE
validate $? "loading shipping data"

systemctl restart shipping &>> $LOG_FILE
validate $? "restart shipping"
