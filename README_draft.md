## Requirements:

1. Install Terraform[https://learn.hashicorp.com/tutorials/terraform/install-cli]

2. Install Ansible[https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#prerequisites-installing-pip]

3. awscli[https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html] and configure it with an access key, with `AmazonEC2FullAccess` and `NetworkAdministrator` policies.

4. Install pywinrm[https://pypi.org/project/pywinrm/]


Steps:

- Clone this repository

- Using aws console, create key-pair and save it in `~/.ssh/<key-pair-name>.pem`

- create `terraform/terraform.tfvars` with the following configuration:

```
## VPC realted
# region
region = "us-east-1"
# environment name for taging
environment = "testing"
# the cidr of the vpc
vpc_cidr = "10.0.0.0/16"
# public and private subnets cidrs, can be multiple
public_subnets_cidr  = ["10.0.1.0/24"]
private_subnets_cidr = ["10.0.10.0/24"]
# ami_id of the ubuntu machine
ami_id = "ami-013f17f36f8b1fefb"
# ami_id of the windows server 2016 machine
win_ami_id = "ami-02642c139a9dfb378"
# size of machine to spin up
instance_type = "t3.small"
# amount of lamp machines to spin up
number_of_instances = 1
# name of the key-pair and location, change this
key_name = "<key-pair-name>"
key_path = "~/.ssh/<key-pair-name>.pem"
```

- update ansible/ansible.cfg with parameters:

```
[defaults]
# ubuntu related
private_key_file= ~/.ssh/<key-pair-name>.pem
remote_user= ubuntu
host_key_checking= False
ansible_ssh_private_key_file= ~/.ssh/<key-pair-name>.pem
ansible_ssh_user= ubuntu
inventory = ./hosts
```

