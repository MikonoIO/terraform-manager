# !bin/sh

###############################################################################################
######################################### DEPENDENCIES ########################################
###############################################################################################

# List of dependencies being install by this script are:
# Terraform | https://developer.hashicorp.com/terraform/install
# Azure CLI | https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

###############################################################################################
#################################### FUNCTIONS & VARIABLES ####################################
###############################################################################################

CLOUD_PROVIDER=("AWS" "AZURE" "GCP")

select_option() {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    printf "\n"
    printf "Choose your respective cloud provider:"
    printf "\n\n"
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""      ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case $(key_input) in
            
            enter) break;;

            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;

            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;

        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

user_select() {
    select_option "$@" 1>&2
    local result=$?
    echo $result
    return $result
}

set_env() {
    NAME=$1
    VALUE=$2

    case ${SHELL} in

        *"bash"* )
            RUNCOM_PATH="~/.profile"
        ;;
        *"zsh"* )
            RUNCOM_PATH="~/.zprofile"
        ;;
        
    esac

    
    bash -c "echo 'export ${NAME}=${VALUE}' >> ${RUNCOM_PATH}"
}

command_exists() {
    if [[ -z $(command -v $1) ]]; then
        return 0
    else
        return 1
    fi
}

moiac_cloud_provider() {
    case $1 in

        *"AWS"* | *"GCP"* | *"AZURE"* )
            return 1
        ;;

        * )
            return 0
        ;;

    esac
}

choose_cloud_provider() {

    case $(user_select ${CLOUD_PROVIDER[@]}) in
        *)
            PROVIDER_VAL="${CLOUD_PROVIDER[$?]}"
            set_env "MOIAC_CLOUD_PROVIDER" ${PROVIDER_VAL}
            export MOIAC_CLOUD_PROVIDER="${PROVIDER_VAL}"
        ;;
    esac 

}

cloud_echo() {

    echo "Environment variable set: \$MOIAC_CLOUD_PROVIDER=${MOIAC_CLOUD_PROVIDER}"

}

###############################################################################################
########################################### PROGRAM ###########################################
###############################################################################################

# Use Machine Identity to install dependencies safely
case $(uname) in

    "Darwin" | "i386" | "Linux" )

        if [[ $(uname) == "Darwin" ]] || [[ $(uname) == "i386" ]]; then
            if command_exists 'brew'; then
                sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            if command_exists 'terraform'; then
                sh -c "brew tap hashicorp/tap"
                sh -c "brew install hashicorp/tap/terraform"
            fi
        else
            if [[ $(cat /etc/os-release) == *"Ubuntu"* ]] || [[ $(cat /etc/os-release) == *"CentOS"* ]]; then 
                if command_exists 'terraform'; then
                    sh -c "apt-get update && apt-get install -y lsb-release && apt-get clean all"
                    sh -c "apt-get update" 
                    sh -c "apt-get install wget -y"
                    sh -c "apt-get install -y gnupg software-properties-common"
                    sh -c """
                        wget -O- https://apt.releases.hashicorp.com/gpg | \
                        gpg --dearmor | \
                        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
                    """
                    sh -c """
                        gpg --no-default-keyring \
                        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
                        --fingerprint
                    """
                    sh -c """
                        echo deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
                        https://apt.releases.hashicorp.com $(lsb_release -cs) main | \
                        tee /etc/apt/sources.list.d/hashicorp.list
                    """
                    sh -c "apt-get update"
                    sh -c "apt-get install terraform -y"
                fi
            fi
        fi

        

        # Install cloud provider CLI if required
        if [ -z "${MOIAC_CLOUD_PROVIDER}" ]; then
            
            choose_cloud_provider

        elif [[ $(moiac_cloud_provider ${MOIAC_CLOUD_PROVIDER}) -eq 1 ]]; then

            echo "${MOIAC_CLOUD_PROVIDER} is already set as your cloud provider"
            
        fi

        case "${MOIAC_CLOUD_PROVIDER}" in 

            "AWS" )

                # echo "TODO"

            ;;

            "AZURE" )

                if [[ $(uname) == "Darwin" ]] || [[ $(uname) == "i386" ]]; then
                    if command_exists 'az'; then
                        sh -c $(brew update)
                        sh -c $(brew install azure-cli)
                    fi
                else
                    if command_exists 'az'; then
                        # sh -c "apt-get update && apt-get install -y lsb-release && apt-get clean all"
                        if [[ $(cat /etc/os-release) == *"Ubuntu"* ]] || [[ $(cat /etc/os-release) == *"CentOS"* ]]; then 
                            sh -c "apt-get install curl -y"
                            sh -c "curl -sL https://aka.ms/InstallAzureCLIDeb | bash"
                        fi
                    fi
                fi
                
            ;;

            "GCP" )

                echo "TODO"

            ;;

            * )
            
                echo "The MOIAC_CLOUD_PROVIDER variable is an unrecognizable value. To continue the installation you will have to refer to the documentation and replace this."

            ;;

        esac
        
    ;;

    * )
        echo "Your machine Identity: $(uname) | Isn't compatible with this repository"
    ;;
    
esac

# if [ -n "${MOIAC_CLOUD_PROVIDER}" ]; then
#     cloud_echo
# fi
