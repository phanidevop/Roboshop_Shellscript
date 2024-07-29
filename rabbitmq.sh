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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash  &>> $LOG_FILE
validate $? "Downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash  &>> $LOG_FILE
validate $? "Downloading rabbitmq script"

dnf install rabbitmq-server -y  &>> $LOG_FILE
validate $? "Install RabbitMQ"

systemctl enable rabbitmq-server   &>> $LOG_FILE
validate $? "Enable RabbitMQ-Server"

systemctl start rabbitmq-server   &>> $LOG_FILE
validate $? "Start RabbitMQ-Server"

rabbitmqctl add_user roboshop roboshop123  &>> $LOG_FILE
validate $? "Enable RabbitMQ-Server"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>> $LOG_FILE
validate $? "setting permission"