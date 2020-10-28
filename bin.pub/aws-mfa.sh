#!/usr/bin/env bash

set -x

TOKEN_CODE=$1
AWS_PROFILE=${AWS_PROFILE:-personal}

if [ ! "$AWS_ACCESS_KEY_ID" ]; then
    echo missing AWS_ACCESS_KEY_ID in env
    exit 1
fi
if [ ! "$AWS_SECRET_ACCESS_KEY" ]; then
    echo missing AWS_SECRET_ACCESS_KEY in env
    exit 1
fi
if [ ! "$AWS_MFA_SERIAL_NUMBER_ARN" ]; then
    echo missing AWS_MFA_SERIAL_NUMBER_ARN
    exit 1
fi

if [ ! "$TOKEN_CODE" ]; then
    echo missing TOKEN_CODE param
    exit 1
fi

creds=$(
    aws sts get-session-token \
        --serial-number $AWS_MFA_SERIAL_NUMBER_ARN \
        --token-code $TOKEN_CODE \
    | jq .Credentials
    )

if [ ! "$(echo $creds | jq .AccessKeyId)" ]; then
    echo auth appears to have failed
    exit 1
fi


aws configure set profile.${AWS_PROFILE}.aws_access_key_id $(echo $creds | jq -r .AccessKeyId)
aws configure set profile.${AWS_PROFILE}.aws_secret_access_key $(echo $creds | jq -r .SecretAccessKey)
aws configure set profile.${AWS_PROFILE}.aws_session_token $(echo $creds | jq -r .SessionToken)
