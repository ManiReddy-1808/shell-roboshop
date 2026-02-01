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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing Python3 and Build Tools"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Roboshop User Created"
else
    echo -e "roboshop user already exists ...$Y SKIPPING $N"
fi

mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading Payment App"

cd /app 
VALIDATE $? "Changing Directory to /app"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "Removing Old App Content"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Extracting Payment App Code"

cd /app 
VALIDATE $? "Changing Directory to /app"

pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATE $? "Installing Python Dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOGS_FILE
VALIDATE $? "Copying Payment Service File"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Reloading SystemD Services"

systemctl enable payment &>>$LOGS_FILE
VALIDATE $? "Enabling Payment Service"

systemctl start payment &>>$LOGS_FILE
VALIDATE $? "Starting Payment Service"
