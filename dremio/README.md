# Installing 

## Copilot 

`brew install aws/tap/copilot-cli`
 
Further instructions on how to install aws copilot on your OS environment can be found [here](https://aws.github.io/copilot-cli/docs/getting-started/install/)


# Running Copilot 
  
Creating an environment in copilot 

`copilot env init --name test --profile default --app dremio`
 - `--name` - name of the environment you want to create
 - `--profile` - the name of the local aws profile to use when deploying ECS cluster
 - `--app` - A name for your application. A Application is a collection of environment and services. 

Deploying infrastructure with copilot run the following command: 

`copilot deploy` 
 
 Copilot will deploy the infrastructure as specified by the `manifest.yml` file in the `copilot` folder. 