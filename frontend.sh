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

dnf install nginx -y &>>LOG_FILE
validate $? "installing nginx"

systemctl enable nginx &>>LOG_FILE
validate $? "enabling nginx"

systemctl start nginx &>>LOG_FILE
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>LOG_FILE
validate $? "removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOG_FILE
validate $? "downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>LOG_FILE
validate $? "extracting frontend code"

cp /home/ec2-user/expense-shell/expense.config /etc/nginx/default.d/expense.conf

systemctl restart nginx &>>LOG_FILE
validate $? "restarting nginx"

