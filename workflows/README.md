# Creating Workflow 

In order to create workflows from blueprint you need a role that allows the blueprint to create the aws resource as well as the ability to pass roles to those resources. The role should have a trust relationship with `glue.awsamazon.com`

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:CreateJob",
                "glue:GetCrawler",
                "glue:GetTrigger",
                "glue:DeleteCrawler",
                "glue:CreateTrigger",
                "glue:DeleteTrigger",
                "glue:DeleteJob",
                "glue:CreateWorkflow",
                "glue:DeleteWorkflow",
                "glue:GetJob",
                "glue:GetWorkflow",
                "glue:CreateCrawler"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::<account-id>:role/<role-name>"
        }
    ]
}
```


# Writing a blue print
 - The blueprint layout script must include a function that generates the entities in your workflow. You can name this function whatever you like. AWS Glue uses the configuration file to determine the fully qualified name of the function
 - The layout function must accept the following input arguments.
    
| Argument | Description | 
|----------|-------------|
| user_params| python dictionary of blueprint parameter names and values.|
| system_params | Python dictionary containing two properties: region and accountId| 


## DependsOn Argument 

#### Notation 

`DependsOn = {dependency1 : state, dependency2 : state, ...}`

The keys in the dictionary represent the **object reference** of the entity, while the values are strings that correspond to the state to watch. Valid States can be found [here](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-jobs-trigger.html#aws-glue-api-jobs-trigger-Condition)

#### Example 

The below example creates a crawler and a glue job that depends on the crawler to succeed on the run.

```
crawler2 = Crawler(Name="my_crawler", ...)
job1 = Job(Name="Job1", ..., DependsOn = {crawler2 : "SUCCEEDED", ...})

```
**Note**

If DependsOn is omitted for an entity, that entity depends on the workflow start trigger.

## WaitForDependencies Argument 

 the `WaitforDependencies` argument defines whether a job or crawler entity should wait until `all` entities on which it depends complete or until `any` completes 

The allowable values are `AND` or `ANY`

## OnSchedule Argument 

 The OnSchedule argument for the Workflow class constructor is a cron expression that defines the starting trigger definition for a workflow.

 If this argument is specified, AWS Glue creates a schedule trigger with the corresponding schedule. If it isn't specified, the starting trigger for the workflow is an on-demand trigger.


# Writing a configuration file 

The blueprint configuration file is a required file that defines the script entry point for generating the workflow, and the parameters that the blueprint accepts. **The file must be named blueprint.cfg.**

Parameters

| Property | Description 
|----------|-----------|
| layoutGenerator |  property specifies the fully qualified name of the function in the script that generates the layout. The format is normally specified as follows`<folder_name>.<scripty_name>.<function_name>` | 
| parameterSpec | property specifies the parameters that this blueprint accepts. [See docs](https://docs.aws.amazon.com/glue/latest/dg/developing-blueprints-code-parameters.html) | 



Example

```
{
    "layoutGenerator": "DemoBlueprintProject.Layout.generate_layout",
    "parameterSpec" : {
           "WorkflowName" : {
                "type": "String",
                "collection": false
           },
           "WorkerType" : {
                "type": "String",
                "collection": false,
                "allowedValues": ["G1.X", "G2.X"],
                "defaultValue": "G1.X"
           },
           "Dpu" : {
                "type" : "Integer",
                "allowedValues" : [2, 4, 6],
                "defaultValue" : 2
           },
           "DynamoDBTableName": {
                "type": "String",
                "collection" : false
           },
           "ScriptLocation" : {
                "type": "String",
                "collection": false
    	}
    }
}
```

**Note** 

Your configuration file must include the workflow name as a blueprint parameter, or you must generate a unique workflow name in your layout script.

# Examples
 More Samples for AWS Blue Prints can be found at the AWS [repository](https://github.com/awslabs/aws-glue-blueprint-libs/tree/master/samples)

# Observations
 - Creates hidden infrastructure within the code for example the triggers that are used to combine workflows
 - For simple use case there is to much variables to populate and no proper in the console. the process becomes tedious, although simplified through s3 and iam role dropdowns other resources like glue catalog tables and database are not available as well as glue connection. 
 - Infrastructure is created within python scripts and therefore does not follow best practices regarding IaC. 
 - The more infrastructure you create within the python script code the more variables needs to be past to the blue print script which result in more copy and paste work in the console, and cluttering of code within the python script and essentially becomes hard to manage within a CI/CD solution and drift detection. 

