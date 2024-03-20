# Data Infrastucture (IaC)

**Disclaimer: :construction: This repository is under development and can only built/run on Unix-based systems for now!**

## Setting up the repository

### Preface

*It's suggested that you set the following environment variables onto the machine this is being forked or cloned to, in order to ensure the smoothest build. Set them either locally or using a remote secret manager:*

```shell
# VAR=[X,Y,Z] Indicates that you can choose any one of the enclosed values
# VAR={X,Y,Z} Indicates that you can choose one or multiple value enclosed values (comma-seperate)
# VAR=X Indicates that you must set the value

export IAC_CLOUD_PROVIDER={AWS,AZURE,GCP} # MUST set this value manually if you have more than one provider
```

### Tutorial

1. Execute the **run** in the /build to instantiate the repository and start personalising it to your infrastructure. Make sure that your environment variables are running contextually via runcom/profile or a secret manager (The following commands may require sudo).

```shell
chmod -fhv 777 build/*;
build/run.sh;
```
