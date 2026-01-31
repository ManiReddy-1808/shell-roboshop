#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD  # or $(pwd)
MONGODB_HOST="mongodb.dawsmani.site"

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
        echo -e "$2 ... $R SUCCESS $N" | tee -a $LOGS_FILE
    else 
        echo -e "$2 ... $G FAILURE $N" | tee -a $LOGS_FILE
    fi
}

dnf list installed nodejs &>>$LOGS_FILE
if [ $? -eq 0 ]; then
    echo -e "NodeJS already installed ... $Y SKIPPING $N"
    exit 0;
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

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Catalogue App"

cd /app 
VALIDATE $? "Changing Directory to /app"

rm -rf /app/* &>>$LOGS_FILE
VALIDATE $? "Removing Old App Content"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "Extracting Catalogue App"

npm install 
VALIDATE $? "Installing NodeJS Dependencies"

#BCurrently we are in app directory, so moving to script dir
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying Catalogue SystemD Service File"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Reloading SystemD"

systemctl enable catalogue &>>$LOGS_FILE
VALIDATE $? "Enabling Catalogue Service"

systemctl start catalogue &>>$LOGS_FILE
VALIDATE $? "Starting Catalogue Service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Copying mongo.repo file"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Installing MONGOSH Client"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOGS_FILE
VALIDATE $? "Loading Catalogue Schema to MONGODB"