#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD  # or $(pwd)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -gt 0 ]; then
    echo -e " $R Please run this script with root user :) $N" | tee -a $LOGS_FILE
    exit 3;
fi

mkdir -p $LOGS_FOLDER

# tee command is used to write the output to log file as well as to the console
VALIDATE(){  
    if [ $1 -eq 0 ]; then
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    else 
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
    fi
}

dnf list installed nginx &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    dnf module disable nginx -y &>>$LOGS_FILE
    VALIDATE $? "Disabling NGINX Module"

    dnf module enable nginx:1.24 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling NGINX 1.24 Module"

    dnf install nginx -y
    VALIDATE $? "Installing NGINX..."
else
    echo -e "NginX already installed.... $Y SKYPPING $N"
fi
systemctl enable nginx &>>$LOGS_FILE
VALIDATE $? "Enabling NGINX"

systemctl start nginx &>>$LOGS_FILE
VALIDATE $? "Starting NGINX"

rm -rf /usr/share/nginx/html/* &>>$LOGS_FILE
VALIDATE $? "Remove default content."

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOGS_FILE
VALIDATE $? "Going to html folder"

unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Unziping frontend code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Copying NGINX Config File"

systemctl restart nginx  &>>$LOGS_FILE
VALIDATE $? "Restarting NGINX Service"