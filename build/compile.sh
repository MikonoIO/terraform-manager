#!bin/sh -e

case ${SHELL} in

    *"bash"* )
        RUNCOM_PATH="${HOME}/.profile"
    ;;
    *"zsh"* )
        RUNCOM_PATH="${HOME}/.zprofile"
    ;;
    
esac

source build/install.sh

MOIAC_CLOUD_PROVIDER=$(bash -c "grep -Eo 'MOIAC_CLOUD_PROVIDER.+' ${RUNCOM_PATH} | tail -n 1")

if [ -n "${MOIAC_CLOUD_PROVIDER}" ]; then

    source build/setup.sh "${MOIAC_CLOUD_PROVIDER}"

fi