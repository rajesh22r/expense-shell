#!/bin/bash

LOG_FOLDER="/var/log/expense"
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

echo -e "$Y script started executing at : $N $(date)" | tee -a $LOG_FILE

dnf install mysql-server -y &>>$LOG_FILE
validate $? "installing mysqlserver"


systemctl enable mysqld &>>$LOG_FILE
validate $? "enabling mysql"

systemctl start mysqld &>>$LOG_FILE
validate $? "starting mysql"

mysql -h mysql.hraje.online -uroot -pExpenseApp@1 &>>$LOG_FILE
if [ $? -ne 0 ]
then 
  echo "mysql root password is not setup, setting up now" | tee -a $LOG_FILE
  mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
  validate $? "setting up root password"
else 
   echo -e "Already setup $Y skipping $N" | tee -a $LOG_FILE
   validate $? "setting up root password"
fi