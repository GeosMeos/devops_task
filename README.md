## Requirements:

- Install Terraform[https://learn.hashicorp.com/tutorials/terraform/install-cli]

- Install Ansible[https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#prerequisites-installing-pip]

- awscli[https://docs.aws.amazon.com/cli/latest/userguide/install-linux.html] and configure it with an access key, with `AmazonEC2FullAccess` and `NetworkAdministrator` policies.

- Install pywinrm[https://pypi.org/project/pywinrm/]

- Install  ansible.windows collaction via `ansible-galaxy collection install ansible.windows`[https://galaxy.ansible.com/ansible/windows]

## Steps:

1. Clone this repository

2. Using aws console, create key-pair and save it in `~/.ssh/<key-pair-name>.pem`, make sure to change permissions via ` sudo chmod 400 ~/.ssh/<key-pair-name>.pem`.

3. create `terraform/terraform.tfvars` with the following configuration:

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


4. update `ansible/ansible.cfg` with parameters:

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

5. run `cd terraform && terraform init && terraform apply` and approve the plan (y).

6. Once terraform is complete, edit the file via `nano ../ansible/winserver` and add update `ansible_password` with the output Administrator_password (if the output is lost, you can check out `../output/Administrator_password`) 

7. navigate back to project root and modify permissions on the scripts via `sudo chmod +x deploy_lamp.sh deploy_winserver.sh`

8. run `./deploy_lamp.sh`

9. run  `./deploy_winserver.sh`

10. via browser navigate to the `lb_dns_name` (terraform outputs), you should get a install page for WordPress.

11. Complete the WordPress installation, log in and navigate to plugins, you should see `printfriendly` and `redirection` installed.

12. connect via rdp (remmina for linux) to the public ip of the winserver with `logviewer` as username and the password from `outputs/logviewer_password`, copy `ansible/logs` private ip and navigate to `\\<private ip>\wp_logs`, log files will be created here. You can verify smb share works by connecting to the lamp machine and creating a file in `/var/log/wordpress/`


## Known issues

- smb share is not created automatically on the logviewer user.
- load balancer is flaky, sometimes it needs a moment.
- since logviewer password is auto generated occasionally it will be generated with characters that smbpasswd doesn't like.