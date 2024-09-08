#!/bin/bash

LOGS_FOLDER="\var\log\expense_shell"
SCRIPT_NAME=$(echo $0 | cut -d "." -F1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log
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
echo " please run the script with root "
exit1
fi
}

VALIDATE()
{
if [ $1 -ne 0 ]
then
echo -e " $R $2 is not success $N " | tee -a $LOG_FILE
else 
echo -e " $G $2 is success $N " | tee -a $LOG_FILE
fi
}

echo -e "$Y script started execution at : $(date) $N"

CHECK_ROOT


dnf install mysql-server -y
VALIDATE $? "Installed mysql"

sytemctl enable mysqld
VALIDATE $? "Enabled mysql"

sytemctl start mysqld
VALIDATE $? "started mysql"

mysql_secure_installtion --set-root-pass ExpenseApp@1

dnf list installed mysql
VALIDATE $? "mysql installed successfully"
