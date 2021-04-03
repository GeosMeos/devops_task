Summary:

Using tf and ansible, configure and dploy on AWS in us-east-1 via t3.small instance.

* LAMP stack
    * Linux Ubuntu 18.04 latest minor (18.04.5) - V
    * Apache2 latest - V
    * Mysql 5.7 - V
    * PHP 7 - V
    * Wordpress latest with plugins:
        * printfriendly - https://wordpress.org/plugins/printfriendly/  - V
        * redirection - https://wordpress.org/plugins/redirection/  - V

* Win Server 2019
    * IIS - V
    * DotNet 4 latest - V
    * local user "logviewer" with auto-generated password - V
    * SMB share to LAMP machine - X

Concepts:
* Load balancer - OK
* Auto scaling - X
* Security (SGs) - OK
* What happens in scaling? how would the environment react?


Requirments:

1. The ability to perform maintenance operations on the site (scaling, updates, etc.) with zero downtime to the website.

2. The ability to scale, both horizontally and vertically, with zero downtime 

3. All required details and credentials should be either provided as parameters to the deployment or exported during the deployment process. 


ToDo:

* tf infrastructure - OK

* tf lamp - OK

* tf winserver2019 - OK

* anisble lamp - OK

* ansible winserver2019 - OK

* ansible SMB share -X

* tf ELB - OK

* questions - OK

* documentation - OK



## HowTo:

1. install ansible(python and pip also), terraform, pywinrm(via pip) and awscli

2. create aws account, create iam user with AmazonEC2FullAccess and NetworkAdministrator and generate access key.

3. configure awscli

4. create key-pair and save the .pem file to ~/.ssh/

5. create terraform/terraform.tfvars with:
```
# VPC realted
region = "us-east-1"
environment = "testing"
vpc_cidr = "10.0.0.0/16"
public_subnets_cidr  = ["10.0.1.0/24"]
private_subnets_cidr = ["10.0.10.0/24"]

# AWS realted
ami_id = "ami-013f17f36f8b1fefb"
win_ami_id = "ami-02642c139a9dfb378"
instance_type = "t3.small"
key_name = "testing-keypair"
key_path = "~/.ssh/testing-keypair.pem"
number_of_instances = 1
```

5. update provider.tf profile(if not using default)

```
cd terraform
terrafrom apply
```

6. update ansible_password in /ansible/winserver with administrator's password - available in /outputs/Administrator_password

7. execute ansible scripts:

```
cd ..
./deploy_lamp.sh
./deploy_winserver.sh
```

