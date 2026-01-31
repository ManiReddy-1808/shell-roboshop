#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
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
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    else 
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
    fi
}

dnf list installed maven
if [ $? -eq 0 ]; then
    echo -e "maven already installed ... $Y SKIPPING $N"
else
    dnf install maven -y &>>LOGS_FILE
    VALIDATE $? "Installing maven"
fi

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Roboshop User Created"
else
    echo -e "roboshop user already exists ...$Y SKIPPING $N"
fi

mkdir -p /app 

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Shipping App"

cd /app 
VALIDATE $? "Changing Directory to /app"

unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "Extracting Shippping App Code"

cd /app 
VALIDATE $? "Changing Directory to /app"

mvn clean package &>>$LOGS_FILE
VALIDATE $? "Building Shipping App"

mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
VALIDATE $? "Renaming Shipping Jar File"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOGS_FILE
VALIDATE $? "Copying service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Reloading SystemD"

systemctl enable shipping &>>$LOGS_FILE
VALIDATE $? "Enabling Shipping Service"

systemctl start shipping &>>$LOGS_FILE
VALIDATE $? "Starting Shipping Service"

dnf list installed mysql &>>$LOGS_FILE
if [ $? -eq 0 ]; then
    echo -e "MySQL client already installed ... $Y SKIPPING $N"
else
    dnf install mysql -y &>>$LOGS_FILE
    VALIDATE $? "Installing MySQL Client"
fi

mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
VALIDATE $? "Creating Shipping Database Schema and loading data"

mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
VALIDATE $? "Creating Shipping App User & loading data"

mysql -h $MONGODB_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE
VALIDATE $? "Creating Shipping Master Data & loading data"

systemctl restart shipping &>>$LOGS_FILE
VALIDATE $? "Restarting Shipping Service"