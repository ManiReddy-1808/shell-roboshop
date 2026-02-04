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

dnf list installed redis &>>$LOGS_FILE
if [ $? -eq 0 ];then
    echo -e "Redis already installed... $Y SKIPPING $N"
else
    dnf module disable redis -y &>>$LOGS_FILE
    VALIDATE $? "Disabling Redis Module"

    dnf module enable redis:7 -y &>>$LOGS_FILE
    VALIDATE $? "Enabling Redis 7 Module"

    dnf install redis -y &>>$LOGS_FILE
    VALIDATE $? "Installing Redis Server"
fi

sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
VALIDATE $? "Update listen address"

sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "Disabling protected mode"

# OR Instead of above 2 lines

#sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
#VALIDATE $? "Allowing remote connections"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "Enabling Redis Service"

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Starting Redis Service"