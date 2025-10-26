#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/mysql-log"
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

dnf install mysql-server -y &>>LOG_FILE
VALIDATE $? "install mysql"
systemctl enable mysqld &>>LOG_FILE
VALIDATE $? "enable mysqld"
systemctl start mysqld &>>LOG_FILE
VALIDATE $? "start mysqld"
mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOG_FILE
VALIDATE $? "setting up sql root password"