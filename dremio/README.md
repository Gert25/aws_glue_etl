# Installing 

## Copilot 

`brew install aws/tap/copilot-cli`
 
Further instructions on how to install aws copilot on your OS environment can be found [here](https://aws.github.io/copilot-cli/docs/getting-started/install/)

# Initializing Copilot 

Run the following to initialize copilot 

`copilot  init`

- Create a name for the application
- Choose `Load Balanced Web Service` for workload type
- Choose `./Dockerfile`for Dockerfile 
- Choose `9047` for port type   

# Destroy infrastructure
`copilot app delete --yes`


# Running Copilot 
  
Creating an environment in copilot 

`copilot env init --name test --profile default --app dremio`
 - `--name` - name of the environment you want to create
 - `--profile` - the name of the local aws profile to use when deploying ECS cluster
 - `--app` - A name for your application. A Application is a collection of environment and services. 

Deploying infrastructure with copilot run the following command: 

`copilot deploy` 
 
 Copilot will deploy the infrastructure as specified by the `manifest.yml` file in the `copilot` folder. 

 # Known Issues

 ## STOPPED (OutOfMemoryError: Container killed due to memory u)
 
 By default copilot deploys your container with minimum memory. Dremio requires at least 4GB of memory to startup. 
 
 Memory increases on ECS has to be updated in corelation with CPU availability. See the AWS [docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html) on the relation between Memory and CPU updates. 

 You can update the ECS container cpu and memory in the `copilot/<app-name>/manifest.yml` file in the memory and cpu section. 

 ```

cpu: 1024       # Number of CPU units for the task.
memory: 4096    # Amount of memory in MiB used by the task.

```

