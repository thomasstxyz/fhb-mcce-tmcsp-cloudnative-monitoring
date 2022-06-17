# Introduction

University Assignment to build a monitoring solution which works with Metrics, Logs, Traces and Open Telemetry.

# Setup

## Terraform

Set the name of your EC2 key pair name.

- on Windows PowerShell:

```
$env:TF_VAR_ssh_key = "my_key_pair"
```

- on Linux/MacOS:

```
export TF_VAR_ssh_key="my_key_pair"
```

Apply Terraform.

```
terraform init
terraform apply
```

<!-- ## Docker Swarm

Login to the manager instance

    ssh ubuntu@<node_ip>

and initialize the swarm.

    export IP=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
    sudo docker swarm init --advertise-addr $IP

The join command with the token will be printed in the console,
it will look something like this:

    docker swarm join --token SWMTKN-1-0f7annisg6js92n1mo9zs3609o51k5fn86i40fx2pe3u241fj1-4dmtaauk3lrt33m0c907a2sge 172.31.12.253:2377

Then login to the worker nodes and join them to the swarm. -->

## Application Installation on Docker

### Elasticsearch

Login to the instance.

    ssh ubuntu@<instance_ip>

Increase max virtual memory areas vm.max_map_count for Elasticsearch.

    sudo sysctl -w vm.max_map_count=262144
    echo "vm.max_map_count=262144" | sudo tee --append /etc/sysctl.conf

Pull the Elasticsearch Docker image.

    docker pull docker.elastic.co/elasticsearch/elasticsearch:8.2.2

Create a new docker network for Elasticsearch and Kibana.

    docker network create elastic

Start Elasticsearch in Docker. A password is generated for the elastic user and output to the terminal, plus an enrollment token for enrolling Kibana.

    docker run -e ES_JAVA_OPTS="-Xms1g -Xmx1g" --name es01 --net elastic -p 9200:9200 -p 9300:9300 -it docker.elastic.co/elasticsearch/elasticsearch:8.2.2

Copy the generated password and enrollment token and save them in a secure location!
Then cancel with `Ctrl + c` and start the container in the background:

    docker start es01

> If you need to reset the password for the elastic user or other built-in users, run the `elasticsearch-reset-password` tool. This tool is available in the Elasticsearch /bin directory of the Docker container. For example: `docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password`

Copy the http_ca.crt security certificate from your Docker container to your local machine.

    docker cp es01:/usr/share/elasticsearch/config/certs/http_ca.crt .

Open a new terminal and verify that you can connect to your Elasticsearch cluster by making an authenticated call, using the http_ca.crt file that you copied from your Docker container. Enter the password for the elastic user when prompted.

    curl --cacert http_ca.crt -u elastic https://localhost:9200

When you start Elasticsearch for the first time, the installation process configures a single-node cluster by default. This process also generates an enrollment token and prints it to your terminal. If you want a node to join an existing cluster, start the new node with the generated enrollment token.

> The enrollment token is valid for 30 minutes. If you need to generate a new enrollment token, run the `elasticsearch-create-enrollment-token` tool on your existing node. This tool is available in the Elasticsearch bin directory of the Docker container.
> For example, run the following command on the existing `es01` node to generate an enrollment token for new Elasticsearch nodes:

    docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node

On your new node, start Elasticsearch and include the generated enrollment token.

    docker run -e ENROLLMENT_TOKEN="<token>" -e ES_JAVA_OPTS="-Xms1g -Xmx1g" --name es02 --net elastic -it docker.elastic.co/elasticsearch/elasticsearch:8.2.2

### Kibana

Pull the Kibana container image.

    docker pull docker.elastic.co/kibana/kibana:8.2.2

Run the Kibana container.

    docker run --name kib-01 --net elastic -p 5601:5601 docker.elastic.co/kibana/kibana:8.2.2

Now visit the Kibana dashboard in a Browser at `http://<instance_ip>:5601`

Paste the Kibana enrollment token and if necessary also the security code from the terminal.

Then log in with the `elastic` user and generated password from before.

Now the Elastic + Kibana Setup is finished!

To setup a Fleet Server, go to `http://<instance_ip>:5601/app/fleet` and follow the steps.

Now you can enroll machines in the Fleet, and configure further integrations.
