# !bin/sh -e
NAME=$1
VALUE=$2

case ${SHELL} in

    *"bash"* )
        RUNCOM_PATH="${HOME}/.bashrc"
    ;;
    *"zsh"* )
        RUNCOM_PATH="${HOME}/.zshrc"
    ;;
    
esac

# Run repository build
RESULT=$(bash -c "build/install.sh")

case RESULT in
    "Your MOIAC_CLOUD_PROVIDER is set as AWS" ) MOIAC_CLOUD_PROVIDER="AWS";;
    "Your MOIAC_CLOUD_PROVIDER is set as AZURE" ) MOIAC_CLOUD_PROVIDER="AZURE";;
    "Your MOIAC_CLOUD_PROVIDER is set as GCP" ) MOIAC_CLOUD_PROVIDER="GCP";;
esac

if [ -n "${MOIAC_CLOUD_PROVIDER}" ]; then

    sh -c "build/setup.sh ${MOIAC_CLOUD_PROVIDER}"

fi

exec "${SHELL}"
