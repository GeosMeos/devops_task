Q: How can we secure the system from intrusion and attack, internal and external?
```
A: There are multiple ways, first i'd remove external access to resources and set up a bastion inside the vpc,
this will ensure only valid users who have the relevant ssh key-pair has access.
Additionally i'd  set up a WAF before the load balancer to monitor and prevent external attacks.
Internally, i'd limit traffic between instances to specific security group.
```
Q: How can we address the log collection in case we need to scale the deployment
horizontally to multiple machines?
```
A: Log collection should be centralized via log collecting tools like elasticsearch.
```

Q: How can we optimize the running costs of the system?
```
A:  
1. rightsize the instance type of the lamp server and the windows server to a more fitting type/family.

2. Since the windows server is used for viewing logs only, i'd schedule it to work only during working hours.

3. Auto scaling with spots - instead of guessing the amount of lamp instances required, use auto scaling along with spot instaces.

4. Switch to ECS - it's cheaper and easy to scale. 
```

Q: BONUS - What mechanism can we provide to “roll-back” the system in case of a bad
update
```
A: Setting up a pipeline with a blue & green environments, controlling the working deployment via load balancer.
```