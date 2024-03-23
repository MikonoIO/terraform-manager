#!bin/sh -e

case ${SHELL} in

    *"bash"* )
        RUNCOM_PATH="${HOME}/.profile"
    ;;
    *"zsh"* )
        RUNCOM_PATH="${HOME}/.zprofile"
    ;;
    
esac

MOIAC_CLOUD_PROVIDER=$(grep -Eo 'MOIAC_CLOUD_PROVIDER.+' ${RUNCOM_PATH} | tail -n 1)
ARM_CLIENT_ID=$(grep -Eo 'ARM_CLIENT_ID.+' ${RUNCOM_PATH} | tail -n 1)
ARM_CLIENT_SECRET=$(grep -Eo 'ARM_CLIENT_SECRET.+' ${RUNCOM_PATH} | tail -n 1)
ARM_SUBSCRIPTION_ID=$(grep -Eo 'ARM_SUBSCRIPTION_ID.+' ${RUNCOM_PATH} | tail -n 1)
ARM_TENANT_ID=$(grep -Eo 'ARM_TENANT_ID.+' ${RUNCOM_PATH} | tail -n 1)

export $MOIAC_CLOUD_PROVIDER $ARM_CLIENT_ID $ARM_CLIENT_SECRET $ARM_SUBSCRIPTION_ID $ARM_TENANT_ID