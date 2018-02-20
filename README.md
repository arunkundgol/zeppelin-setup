# Notes

replace the following command with your desired s3 location in bootstrap_action.sh

    aws s3 cp s3://<s3-bucket>/zeppelin-bucket/resources/ zeppelinsetup --recursive

Push the folder setupZeppelin to your desired S3 location.

## Tasks

- Set Zeppelin to use S3 backed notebooks with Spark on Amazon EMR
- Set Anaconda as default python interpreter in Zeppelin
- Setting up Shiro authentication in Zeppelin

## Getting started

Make sure you have the resources before beginning:

- AWS Command line interface installed
- An SSH client
- A key pair in the region where you'll launch the Zeppelin instance
- An S3 bucket in same region to store your Zeppelin notebooks, and to transfer files from EMR to your Zeppelin instance
- IAM permissions to create S3 buckets, launch EC2 instances, and create EMR clusters

## Create an EMR cluster

The first step is to set up an EMR cluster.

1. On the Amazon EMR console, choose Create cluster.
2. Choose Go to advanced options and enter the following options:
    1. Vendor: Amazon
    2. We require Hadoop, Zeppelin, Ganglia, and Spark are selected.
    3. In the Add steps section, for Step type, choose Custom JAR, and select configure.
        1. Change name to "custom bootstrap action"
        2. in `jar location` add `s3://region.elasticmapreduce/libs/script-runner/script-runner.jar`

        **replace** `region` **with the region in which you've created your EMR instance**. For example if your region is eu-west-1 the jar location is in `s3://eu-west-2.elasticmapreduce/libs/script-runner/script-runner.jar`. _The script runner allows you run a script at any time during the step process._
        3. In `arguments` add `s3://ah-aim-dn-applications/setupZeppelin/bootstrapaction.sh`.
3. Choose Add, Next.
4. On the Hardware Configuration page, select your VPC and the subnet where you want to launch the cluster, keep the default selection of one master and two core nodes of m3.xlarge, and choose Next.
5. On the General Options page, give your cluster a name (e.g., Spark-Cluster) and choose Next.
6. On the Security Options page, for EC2 key pair, select a key pair. Keep all other settings at the default values and choose Create cluster.

Your three-node cluster takes a few moments to start up. Your cluster is ready when the cluster status is Waiting.

## Discussion

### Enabling Shiro

Apache Shiro is a powerful and easy-to-use Java security framework that performs authentication, authorization, cryptography, and session management.

### Using S3 backed notebooks with Spark on EMR

The zeppelin-env.sh, and zeppelin-site.xml files are already updated and stored in the resources directory. However, if you'd like to set up again - use the following instructions.

1. the EMR works through IAM profile. So, you don't need to store AWS credentials on EMR.
2. In order to do this, we'll first need to create a S3 bucket with the following folder structure.

        bucket_name/
        username/
            notebook/
3. We can do **either** of th following methods
    1. set the environment variable in the zeppelin-env.sh

            export ZEPPELIN_NOTEBOOK_S3_BUCKET = bucket_name
            export ZEPPELIN_NOTEBOOK_S3_USER = username

    2. uncomment and replace value `zeppelin.notebook.s3.user` with `username` and replace value of `zeppelin.notebook.s3.bucket` with `bucket_name` in zeppelin-site.xml

            <!-- Amazon S3 notebook storage -->
            <!-- Creates the following directory structure: s3://{bucket}/{username}/{notebook-id}/note.json -->

            <property>
            <name>zeppelin.notebook.s3.user</name>
            <value>username</value>
            <description>user name for s3 folder structure</description>
            </property>

            <property>
            <name>zeppelin.notebook.s3.bucket</name>
            <value>bucket_name</value>
            <description>bucket name for notebook storage</description>
            </property>

            <property>
            <name>zeppelin.notebook.s3.endpoint</name>
            <value>s3.amazonaws.com</value>
            <description>endpoint for s3 bucket</description>
            </property>

            <property>
            <name>zeppelin.notebook.storage</name>
            <value>org.apache.zeppelin.notebook.repo.S3NotebookRepo</value>
            <description>notebook persistence layer implementation</description>
            </property>

### Services on EMR use upstart

Note - services on EMR use upstart, and the supported way to restart them is to use `sudo stop <service name>`; `sudo start <service name>`(the start and stop commands are in /sbin, which is in the PATH by default).

- <https://stackoverflow.com/questions/42032490/how-can-i-get-zeppelin-to-restart-cleanly-on-an-emr-cluster>
- <https://aws.amazon.com/premiumsupport/knowledge-center/restart-service-emr/>

## Links

- <https://aws.amazon.com/blogs/big-data/running-an-external-zeppelin-instance-using-s3-backed-notebooks-with-spark-on-amazon-emr/>
- <https://dziganto.github.io/zeppelin/spark/zeppelinhub/emr/anaconda/tensorflow/shiro/s3/theano/bootstrap%20script/EMR-From-Scratch/>