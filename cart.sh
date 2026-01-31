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

dnf list installed nodejs &>>$LOGS_FILE
if [ $? -eq 0 ]; then
    echo -e "NodeJS already installed ... $Y SKIPPING $N"
else
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disabling NodeJS Module"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling NodeJS 20 Module"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Installing NodeJS"
fi

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Roboshop User Created"
else
    echo -e "roboshop user already exists ...$Y SKIPPING $N"
fi

mkdir -p /app 

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Cart App"

cd /app 
VALIDATE $? "Changing Directory to /app"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "Removing Old App Content"

unzip /tmp/cart.zip &>>$LOGS_FILE
VALIDATE $? "Extracting Cart App Code"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing NodeJS Dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Reloading SystemD"

systemctl enable cart &>>$LOGS_FILE
VALIDATE $? "Enabling Cart Service"

systemctl start cart &>>$LOGS_FILE
VALIDATE $? "Starting Cart Service"