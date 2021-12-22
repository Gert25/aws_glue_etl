
## Running Locally  

## Install docker image

Pull docker image 
   `docker pull amazon/aws-glue-libs:glue_libs_1.0.0_image_01`

1. Start the container in the background
```
docker run -itd \
-v ${PWD}/scripts:/scripts \
-v ${PWD}/data:/data \
-v ${PWD}/output:/output \
--name glue amazon/aws-glue-libs:glue_libs_1.0.0_image_01
```

2. execute a bash on the container 

`docker exec -it glue bash`

3. Start pyspark execution 
`/home/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/bin/pyspark`

**OR**

3. Run glue jobs within the container
```
/home/spark-2.4.3-bin-spark-2.4.3-bin-hadoop2.8/bin/spark-submit /scripts/job1.py \
--JOB_NAME "local_test" \
--OUTPUT_SRC "output" \
--INPUT_SRC "Salaries.csv" \
--SRC_TYPE "csv" \
--ENV "local" \
--OUTPUT_FORMAT "csv" \
--CONN_TYPE "s3"
```
### Running Jupyter notebook 

Start the container using the following command 

```
docker run -itd -p 8888:8888 -p 4040:4040 \
-v ~/.aws:/root/.aws:ro \
-v ${PWD}/scripts/:/home/jupyter/jupyter_default_dir/scripts \
-v ${PWD}/data/:/home/jupyter/jupyter_default_dir/data \
--name glue_jupyter amazon/aws-glue-libs:glue_libs_1.0.0_image_01 /home/jupyter/jupyter_start.sh
```


Start the notebook in your browser by visiting the address `http://localhost:8888`

**NOTE** Ensure you run a pyspark shell within jupyternotebook when working with the glue context

Jupyter notebook home directory 

`/home/jupyter/jupyter_default_dir`

