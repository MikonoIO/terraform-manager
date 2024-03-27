#!bin/sh -e

case ${SHELL} in

    *"bash"* )
        RUNCOM_PATH="${HOME}/.profile"
    ;;
    *"zsh"* )
        RUNCOM_PATH="${HOME}/.zprofile"
    ;;
    
esac

if [[ "${CIRCLE_PROJECT_ID}" == "${CIRCLE_IDENTIFIER}" ]]; then
    $(echo '\033[B' '\r' | build/install.sh)
else
    build/install.sh
fi

if [ -n "${MOIAC_CLOUD_PROVIDER}" ]; then 
    MOIAC_CLOUD="$MOIAC_CLOUD_PROVIDER"
else
    MOIAC_CLOUD=$(grep -Eo 'MOIAC_CLOUD_PROVIDER.+' ${RUNCOM_PATH} | tail -n 1)
fi

if [ -n "${MOIAC_CLOUD}" ]; then

    source build/setup.sh "${MOIAC_CLOUD}"

fi