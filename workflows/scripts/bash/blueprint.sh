 aws glue --profile ${profile} --region ${region} create-blueprint \
 --name ${blueprint_name} \
 --description "${blueprint_description}" \
 --blueprint-location ${blueprint_script}
