#!bin/sh -e
set_env() {
    NAME=$1
    VALUE=$2

    case ${SHELL} in

        *"bash"* )
            RUNCOM_PATH="${HOME}/.profile"
        ;;
        *"zsh"* )
            RUNCOM_PATH="${HOME}/.zprofile"
        ;;
        
    esac

    bash -c "echo \"export ${NAME}="\""${VALUE}"\""\" >> ${RUNCOM_PATH}"
}

connect_azure () {

    # Login if not logged in
    echo "Checking if azure logged in:"
    
    LOGIN_RESULT=$(sh -c "az account list")

    if [[ "$LOGIN_RESULT" == "[]" ]]; then
        echo "Logging into azure..."
        sh -c "az login --use-device-code"
    fi
    echo
    echo Logged into azure with: $(az ad signed-in-user show)
    echo

}

setup_azure () {

    # Set the subscription in use and create service principal
    if [ -n "${MOIAC_PRINCIPAL_ID}" ]; then
        sh -c "az account set --subscription \"${MOIAC_PRINCIPAL_ID}\""
    
        # Create service principal and export the variables to the wider environment
        SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --role Contributor --scopes /subscriptions/${MOIAC_PRINCIPAL_ID})
        
        APPLICATION_BASE=$(echo "${SERVICE_PRINCIPAL}" | grep -Eo '"appId.+')
        APPLICATION_VAR=$(echo "${APPLICATION_BASE}" | cut -c 10-) 
        APPLICATION_VAL=$(echo "${APPLICATION_VAR}" | grep -Eo '[^", ]+')
        PASSWORD_BASE=$(echo "${SERVICE_PRINCIPAL}" | grep -Eo '"password.+')
        PASSWORD_VAR=$(echo "${PASSWORD_BASE}" | cut -c 12-) 
        PASSWORD_VAL=$(echo "${PASSWORD_VAR}" | grep -Eo '[^", ]+')   
        TENANT_BASE=$(echo "${SERVICE_PRINCIPAL}" | grep -Eo '"tenant.+')
        TENANT_VAR=$(echo "${TENANT_BASE}" | cut -c 11-) 
        TENANT_VAL=$(echo "${TENANT_VAR}" | grep -Eo '[^", ]+')

        set_env "ARM_CLIENT_ID" ${APPLICATION_VAL}
        set_env "ARM_CLIENT_SECRET" ${PASSWORD_VAL}
        set_env "ARM_SUBSCRIPTION_ID" ${MOIAC_PRINCIPAL_ID}
        set_env "ARM_TENANT_ID" ${TENANT_VAL}

    else
        echo
        echo 'Setup your MOIAC_PRINCIPAL_ID env variable, refer to the documentation at https://github.com/MikonoIO/terraform-manager for more.'
    fi

}

if [ -z "${MOIAC_CLOUD_PROVIDER}" ]; then
    MOIAC_CLOUD_PROVIDER=$1
fi

case ${MOIAC_CLOUD_PROVIDER} in 

    *"AWS"* )

    ;;

    *"AZURE"* )

        connect_azure
        setup_azure
        
    ;;

    *"GCP"* )

    ;;

    * )

        echo "The MOIAC_CLOUD_PROVIDER variable is an unrecognizable value (${MOIAC_CLOUD_PROVIDER}). To continue the installation you will have to refer to the documentation and replace this."

    ;;

esac
