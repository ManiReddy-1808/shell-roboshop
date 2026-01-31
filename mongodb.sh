#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo.repo file"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enabling mongodb"

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Started mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing Remote Connection"

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "Restarted MongoDB"

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOGS_FILE
    VALIDATE $? "Loading Catalogue Schema to MONGODB"
else
    echo -e "Catalogue DB already exists ... $Y SKIPPING $N"
fi

systemctl restart catalogue &>>$LOGS_FILE
VALIDATE $? "Restarting catalogue"