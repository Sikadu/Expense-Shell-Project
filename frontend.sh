#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

CHECK_ROOT( ) 
{
if [ $USERID -ne 0 ]
then
echo -e "$R Please run this script with root priveleges $N" | tee -a $LOG_FILE
exit1
fi
}

VALIDATE()
{
if [ $1 -ne 0 ]
then
echo -e "$2 is...$R FAILED $N"  | tee -a $LOG_FILE
        exit 1
    else
echo -e "$2 is... $G SUCCESS $N" | tee -a $LOG_FILE
fi
}

echo -e "$Y script started execution at : $(date) $N"

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Install nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable nginx"1A

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"
    
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default website"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloding frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extract frontend code"

cp /home/ec2-user/Expense-Shell-Project/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarted Nginx"