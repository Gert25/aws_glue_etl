
aws glue --profile ${profile} --region ${region}  start-blueprint-run \
--blueprint-name ${BlueprintName} --role-arn ${BlueprintRoleArn}  \
--parameters '{"WorkflowName":"${WorkflowName}","IAMRole":"${IAMRole}", "DestinationDatabaseName": "${DestinationDatabaseName}","InputDataLocation":"${InputDataLocation}","DestinationTableName":"${DestinationTableName}","OutputDataLocation":"${OutputDataLocation}","NumberOfWorkers":${NumberOfWorkers},"ScriptLocation":"${ScriptLocation}"}'

