#!/bin/bash

LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOG_FOLDER

userid=$(id -u)
if [ $userid -ne 0 ]
then 
  echo -e " $R please run through root privileges $N"
  exit 1
fi

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

validate (){
    if [ $1 -ne 0 ]
    then 
       echo -e " $2 is $R failed.. $N check it " | tee -a $LOG_FILE
    else 
       echo -e "  $2 is $G success $N" | tee -a $LOG_FILE
    fi
}

echo -e "$Y script started executing at : $N $(date)" | tee -a $LOG_FILE

dnf module disable nodejs -y &>>$LOG_FILE
validate $? "disable default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enable nodejs : 20"

dnf install nodejs -y &>>$LOG_FILE
validate $? "installing nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then 
   echo "user expense doesnt exit create user" &>>$LOG_FILE
   useradd expense
   validate $? "creating expense user"
else
echo -e " expense user already created $Y skipping $N "
fi

mkdir -p /app
validate $? "creating app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
validate $? "downloading backend application code"

cd /app 
rm -rf /app/* #remove the existing code

unzip /tmp/backend.zip &>>$LOG_FILE
validate $? "extracting backend apllication code"

npm install &>>$LOG_FILE

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#load the data

dnf install mysql -y &>>$LOG_FILE
validate $? "installing mysql client"

mysql -h mysql.hraje.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
validate $? "new schema loading"

systemctl daemon-reload &>>$LOG_FILE
validate $? "daemon reload"

systemctl enable backend &>>$LOG_FILE
validate $? "enabled backend"

systemctl restart backend &>>$LOG_FILE
validate $? "restart backend"

