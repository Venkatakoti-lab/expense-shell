#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/backend-logs"
LOG=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$LOG-$TIMESTAMP.log"
VALIDATE (){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 : $R FAILED $N"
        exit 1
    else
        echo -e "$2 : $G SUCCESS $N"
    fi
}
CHECK_ROOT (){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: Please run this script as root user"
        exit 1
    fi
}
echo "This script runs at: $TIMESTAMP"
mkdir -p $LOGS_FOLDER
CHECK_ROOT
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable nodejs default version"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable required nodejs version"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install nodejs"
id expense
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE
    VALIDATE $? "useradd expense"
else
    echo -e "user already exists..$Y SKIPPING $N"
fi 
mkdir -p /app &>>$LOG_FILE
VALIDATE $? "create directory"
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "downloading backend code"

cd /app 
rm -rf /app/*

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "unzipping the code"
npm install &>>$LOG_FILE
VALIDATE $? "install npm dependencies"
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service 

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon reload"
systemctl start backend &>>$LOG_FILE
VALIDATE $? "start backend"
systemctl enable backend &>>$LOG_FILE
VALIDATE $? "enable backend"
dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "install mysql"
mysql -h 172.31.29.71 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "load schema"
systemctl restart backend &>>$LOG_FILE
VALIDATE $? "restart backend"
