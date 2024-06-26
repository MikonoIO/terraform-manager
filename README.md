# Data Infrastucture (IaC)

**Disclaimer: :construction: This repository is under development until v1.0.0 has been released.**

[![CircleCI](https://dl.circleci.com/status-badge/img/circleci/4Ht57nhScTYXLBaHFizYi2/A3UnA97BfVk5ac3fsT1tUh/tree/main.svg?style=shield&circle-token=CCIPRJ_WAptPKPRXicQZ6fr38PMrS_aedd54725903cf3dd6a1180bb91ae1a577b152f8)](https://dl.circleci.com/status-badge/redirect/circleci/4Ht57nhScTYXLBaHFizYi2/A3UnA97BfVk5ac3fsT1tUh/tree/main)

## Setting up the repository

### Prerequisites

Ensure that you have the following requirements fulfilled:

- Your user should have administrative/root level access (non-reliant on sudo before commands).

*It's suggested that you set the following environment variables onto the machine this is being forked or cloned to, in order to ensure the smoothest build. Set them either locally or using a remote secret manager:*

```shell
# VAR=(X,Y,Z) Indicates that you can write in any nymber of values, must be comma seperated
# VAR=[X,Y,Z] Indicates that you can choose any one of the enclosed values
# VAR={X,Y,Z} Indicates that you can choose one or multiple value enclosed values (comma-seperate)
# VAR=X Indicates that you must set the value

# Your cloud provider/s
export MOIAC_CLOUD_PROVIDER={AWS,AZURE,GCP} #Eg: example MOIAC_CLOUD_PROVIDER=AWS

### For users of Azure
# The azure billing subscription ID for the infrastructure you'll manage with this user
export MOIAC_SUBSCRIPTION_ID=X # Eg: MOIAC_SUBSCRIPTION_ID=Snjknd12NKSl_as2-

```

### Tutorial

1. From the root of the repository directory, run the below command to instantiate the repository and start personalising it to your infrastructure. Make sure that your environment variables are running contextually via any of the following:
    - A secret manager.
    - The runcom or profile scripts on your machine.

```shell
# Run this
build/compile.sh && . build/run.sh;
```
