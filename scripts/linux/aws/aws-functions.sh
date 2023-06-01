#!/bin/bash

<<'MULTILINE-COMMENT'
    Requirments: none
    Description: Script for aws automations
    Author: Marcos Silvestrini
    Date: 18/05/2023
MULTILINE-COMMENT

# Set language/locale and encoding
export LANG=C

# Scriptpath
path=$(readlink -f "${BASH_SOURCE:-$0}")
DIR_PATH=$(dirname "$path")

# Log functions
LOGFUNCTIONS="$DIR_PATH/aws-functions.log"
echo "############### Begin Log ###################" >"$LOGFUNCTIONS"
date=$(date '+%Y-%m-%d %H:%M:%S')
echo "Date: $date">> "$LOGFUNCTIONS"

# Variables
JSON=security/.aws-secrets
export AWS_DEFAULT_REGION="us-east-1"    

# Functio for login in Azure Portal
LoginAWS(){
    echo "Set credential for user $1"      
    echo "Set credential for user $1" >>"$LOGFUNCTIONS"
    case $1 in
        "terraform")                
                export AWS_ACCESS_KEY_ID=$(jq -r .terraform_access_key $JSON)
                export AWS_SECRET_ACCESS_KEY=$(jq -r .terraform_secret_key $JSON) 
                ;;
        "ansible")
                export AWS_ACCESS_KEY_ID=$(jq -r .ansible_access_key $JSON)
                export AWS_SECRET_ACCESS_KEY=$(jq -r .ansible_secret_key $JSON) 
                ;;
        *)
                echo "Not a valid argument"
                echo
                ;;
    esac        
    LOGIN="$(aws iam list-users | jq -r .Users[].UserName)"
    if [ "$LOGIN" == "$1" ] ;    
    then            
        echo "Login in AWS with IAM [$1:$LOGIN] has successfully!!!"      
        echo "Login in AWS with IAM [$1:$LOGIN] has successfully!!!" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
   else 
        echo "Login in AWS with IAM [$1:$LOGIN] failed. This IAM user not found in AWS account. Please check in AWS Console"
        echo "Login in AWS with IAM [$1:$LOGIN] failed. This IAM user not found in AWS account. Please check in AWS Console" >>"$LOGFUNCTIONS"
        echo "----------------------------------------------------"
   fi
}
