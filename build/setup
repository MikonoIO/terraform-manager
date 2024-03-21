# !bin/sh -e
set_env() {
    NAME=$1
    VALUE=$2

    case ${SHELL} in

        *"bash"* )
            RUNCOM_PATH="~/.bashrc"
        ;;
        *"zsh"* )
            RUNCOM_PATH="~/.zshrc"
        ;;
        
    esac

    sh -c "echo \"export ${NAME}="\""${VALUE}"\""\" >> ${RUNCOM_PATH} && . ${RUNCOM_PATH}"
}

connect_azure () {

    # Login if not logged in
    
    echo "Checking if azure logged in:"
    echo

    if [[ $(az account show) == *"environmentName"* ]]; then
        echo "Logging into azure..."

        sh -c "az login --use-device-code"

    fi

    echo Logged into azure with: $(az ad signed-in-user show)

    # Set the subscription in use

    sh -c "az account set --subscription \"${AZ_SP_SUBSCRIPTION_ID}\""

}

setup_azure () {

    # Create the subscription
    az "ad sp create-for-rbac --role=\"Contributor\" --scopes="/subscriptions/${AZ_SP_SUBSCRIPTION_ID}\""

    sh -c echo "export ARM_CLIENT_ID=${AZ_SP_CLIENT_ID}" >>
    sh -c echo "export ARM_CLIENT_SECRET=${AZ_SP_CLIENT_PASS}"
    sh -c echo "export ARM_SUBSCRIPTION_ID=${AZ_SP_SUBSCRIPTION_ID}"
    sh -c echo "export ARM_TENANT_ID=${AZ_SP_TENANT_ID}"

}

connect_azure
setup_azure