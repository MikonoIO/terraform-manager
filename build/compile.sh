

case ${SHELL} in

    *"bash"* )
        RUNCOM_PATH="${HOME}/.profile"
    ;;
    *"zsh"* )
        RUNCOM_PATH="${HOME}/.zprofile"
    ;;
    
esac

source build/install.sh

case $(grep -Eo 'MOIAC_CLOUD_PROVIDER.+' ${RUNCOM_PATH} | tail -n 1) in
    "MOIAC_CLOUD_PROVIDER=AWS" ) MOIAC_CLOUD_PROVIDER="AWS";;
    "MOIAC_CLOUD_PROVIDER=AZURE" ) MOIAC_CLOUD_PROVIDER="AZURE";;
    "MOIAC_CLOUD_PROVIDER=GCP" ) MOIAC_CLOUD_PROVIDER="GCP";;
esac


if [ -n "${MOIAC_CLOUD_PROVIDER}" ]; then

    . build/setup.sh "${MOIAC_CLOUD_PROVIDER}"

fi