#!/bin/bash

LOG_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOG_FOLDER

userid=$(id -u)
if [ $userid -ne 0 ]
then 
  echo -e "$R please run through root privileges $N"
  exit 1
fi

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

validate (){
    if [ $1 -ne 0 ]
    then 
       echo -e "$R $2 is  failed.. $N check it " | tee -a $LOG_FILE
    else 
       echo -e " $G $2 is  success $N" | tee -a $LOG_FILE
    fi
}

echo "script started executing at : $(date)" | tee -a $LOG_FILE

dnf install mysql-server -y
validate $? "installing mysqlserver"


systemctl enable mysqld
validate $? "enabling mysql"

systemctl start mysqld
validate $? "starting mysql"

mysql -h 172.31.47.10 -u root -p ExpenseApp@1 -e 'show databes;'
if [ $? -ne 0 ]
then 
  echo "mysql root password is not setup, setting up now"
  mysql_secure_installation --set-root-pass ExpenseApp@1
  validate $? "setting up root password"
else 
   echo -e "Already setup $Y skipping $N"
   validate $? "setting up root password"
fi