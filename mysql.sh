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

 dnf module disable mysql -y &>> $LOG_FILE
 validate $? "Disable mysql module"
 
 cp /home/centos/shell_script/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOG_FILE
 validate $? "Copying mysql repo"
 
dnf install mysql-community-server -y &>> $LOGFILE
validate $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGFILE 
validate $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOGFILE
validate $? "Starting  MySQL Server" 

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
validate $? "Setting  MySQL root password"

#  mysql -uroot -pRoboShop@1  &>> $LOG_FILE
#  validate $? "Validating MySQL root password"