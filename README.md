Summary:

Using tf and ansible, configure and dploy on AWS in us-east-1 via t3.small instance.

* LAMP stack
    * Linux Ubuntu 18.04 latest minor (18.04.5)
    * Apache2 latest
    * Mysql 5.7
    * PHP 7
    * Wordpress latest with plugins:
        * printfriendly - https://wordpress.org/plugins/printfriendly/
        * redirection - https://wordpress.org/plugins/redirection/

* Win Server 2019
    * IIS
    * DotNet 4 latest
    * local user "logviewer" with auto-generated password
    * SMB share to LAMP machine

Concepts:
* Load balancer
* Auto scaling
* Security (SGs)
* What happens in scaling? how would the environment react?


Requirments:

1. The ability to perform maintenance operations on the site (scaling, updates, etc.) with zero downtime to the website.

2. The ability to scale, both horizontally and vertically, with zero downtime 

3. All required details and credentials should be either provided as parameters to the deployment or exported during the deployment process. 


ToDo:

tf infrastructure - OK

tf lamp - OK

tf winserver2019 - OK

anisble lamp - 

ansible winserver2019

tf ASG

tf ALB
