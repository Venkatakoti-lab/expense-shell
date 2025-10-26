#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/frontend-log"
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

echo  "This script executed at: $TIMESTAMP" &>>$LOG_FILE
CHECK_ROOT
mkdir -p $LOGS_FOLDER &>>LOG_FILE

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "install nginx"
systemctl enable nginx &>>LOG_FILE
VALIDATE $? "enable nginx"
systemctl start nginx &>>LOG_FILE
VALIDATE $? "start nginx"
rm -rf /usr/share/nginx/html/* &>>LOG_FILE
VALIDATE $? "Removing existing version of code"
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip 
VALIDATE $? "download frontend code" &>>LOG_FILE
cd /usr/share/nginx/html &>>LOG_FILE
VALIDATE $? "Moving to HTML directory"
unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "unzipping the frontend code"
cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense config"
systemctl restart nginx &>>LOG_FILE
VALIDATE $? "restart nginx"