# !bin/sh -e

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
            RUNCOM_PATH="~/.bashrc"
        ;;
        *"zsh"* )
            RUNCOM_PATH="~/.zshrc"
        ;;
        
    esac

    sh -c "echo \"export ${NAME}="\""${VALUE}"\""\" >> ${RUNCOM_PATH} && . ${RUNCOM_PATH}"
}

command_exists() {
    if [[ -z $(command -v $1) ]]; then
        return 0
    else
        return 1
    fi
}

iac_cloud_provider() {
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
            export IAC_CLOUD_PROVIDER=${CLOUD_PROVIDER[$?]}
        ;;
    esac 

    echo "Environment variable set:"
    echo 
    echo "\$IAC_CLOUD_PROVIDER=${IAC_CLOUD_PROVIDER}"
    echo 
}

###############################################################################################
########################################### PROGRAM ###########################################
###############################################################################################

# Use Machine Identity to install dependencies safely
case $(uname) in

    # Instsallations
    "Darwin" | "i386" | "Ubuntu" | "Debian" )

        # Install Homebrew if required
        if command_exists 'brew'; then
            sh -c $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
        fi

        # Install Terraform if required
        if command_exists 'terraform'; then
            sh -c $(brew tap hashicorp/tap)
            sh -c $(brew install hashicorp/tap/terraform)
        fi
        
        # Install cloud provider CLI if required
        if [ -z ${IAC_CLOUD_PROVIDER} ]; then
            
            echo "The IAC_CLOUD_PROVIDER variable needs to be set globally."
            echo "Choose the cloud provider you'd like to manage:"
            echo 
            choose_cloud_provider
            set_env "IAC_CLOUD_PROVIDER" "${IAC_CLOUD_PROVIDER}"

        elif [[ $(iac_cloud_provider ${IAC_CLOUD_PROVIDER}) -eq 1 ]]; then

            echo "The IAC_CLOUD_PROVIDER variable is currently unusable (${IAC_CLOUD_PROVIDER}). To continue the installation we will have to replace this. Would you like to continue?:"
            echo
            case $(user_select "NO" "YES") in
                0 )
                    echo "Exiting installation process..."
                ;;
                1 )
                    echo "Choose the cloud provider you'd like to manage:"
                    echo 
                    choose_cloud_provider
                    set_env "IAC_CLOUD_PROVIDER" "${IAC_CLOUD_PROVIDER}"
                ;;
            esac
        else
            echo "Your IAC_CLOUD_PROVIDER is set as ${IAC_CLOUD_PROVIDER}"
        fi

        case ${IAC_CLOUD_PROVIDER} in 

            *"AWS"* )

                echo "TODO"

            ;;

            *"AZURE"* )

                # Install Azure CLI if required
                if command_exists 'az'; then
                    sh -c $(brew update)
                    sh -c $(brew install azure-cli)
                fi
                
            ;;

            *"GCP"* )

                echo "TODO"

            ;;

            * )

                echo "The IAC_CLOUD_PROVIDER variable is an unrecognizable value (${IAC_CLOUD_PROVIDER}). To continue the installation you will have to refer to the documentation and replace this."

            ;;

        esac
        
        
    ;;

    * )
        echo "Your machine Identity: $(uname) | Isn't compatible with this repository"
    ;;
    
esac