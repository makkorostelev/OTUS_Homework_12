# OTUS_Homework_12
 
Project creates kubernetes cluster and wordpress installation .\

### Prerequisite
- **kubectl v1.29.3**
- **Yandex Cloud CLI 0.121.0**


To work with the project you need to write your data into variables.tf.\
![Variables](https://github.com/makkorostelev/OTUS_Homework_12/blob/main/Screenshots/variables.png)\
Then enter the commands:
`terraform init`\
`terraform apply`

After ~15 minutes project will be initialized and run:\
Below there is an example of successful set up:

```
terraform_data.run_ansible (local-exec): NAME        TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
terraform_data.run_ansible (local-exec): wordpress   LoadBalancer   10.96.177.132   <pending>     80:30933/TCP   1s
terraform_data.run_ansible: Creation complete after 3s [id=4fc56b2a-b4ea-560d-a2b0-df88db506cad]

```
To get an external ip address:
kubectl get svc wordpress
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
wordpress   LoadBalancer   10.96.177.132   158.160.156.247   80:30933/TCP   3m23s

You can go to http://EXTERNAL-IP and add your wordpress template to that installation :\
![Wordpress](https://github.com/makkorostelev/OTUS_Homework_12/blob/main/Screenshots/wordpress.png)
