# Terraform Cloud Getting Started Guide Example

This is an example Terraform configuration intended for use with the [Terraform Cloud Getting Started Guide](https://learn.hashicorp.com/terraform/cloud-gettingstarted/tfc_overview).

## What will this do?

This is a Terraform configuration that will create an EC2 instance in your AWS account. 

When you set up a Workspace on Terraform Cloud, you can link to this repository. Terraform Cloud can then run `terraform plan` and `terraform apply` automatically when changes are pushed. For more information on how Terraform Cloud interacts with Version Control Systems, see [our VCS documentation](https://www.terraform.io/docs/cloud/run/ui.html).

## What are the prerequisites?

You must have an AWS account and provide your AWS Access Key ID and AWS Secret Access Key to Terraform Cloud. Terraform Cloud encrypts and stores variables using [Vault](https://www.vaultproject.io/). For more information on how to store variables in Terraform Cloud, see [our variable documentation](https://www.terraform.io/docs/cloud/workspaces/variables.html).

The values for `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` should be saved as environment variables on your workspace.


pre-requisites:
---------------
install:
 - awscli (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
 - kubectl (https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
 - eksctl (https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html#installing-eksctl)
 
practical setup:
----------------
Note: this takes about 25 mins to complete and have an EKS cluster up and running

1. Start AWS Cloud Playground
2. Copy the cloud_user's Access ID and Secret Access Key
3. configure awscli (using cloud user):
    aws configure --profile LABS
    <ACCESS ID>
    <SECRET ACCESS KEY>
    us-east-1
    json
4. create IAM user:
    aws iam create-group --group-name G_EKSAdmin --profile ACGCP
    aws iam create-user --user-name EKSAdmin --profile ACGCP
    aws iam add-user-to-group --user-name EKSAdmin --group-name G_EKSAdmin --profile ACGCP
    aws iam attach-group-policy --group-name G_EKSAdmin --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --profile ACGCP
    aws iam create-login-profile --user-name EKSAdmin --password ACG_EKSAdmin_P01 --no-password-reset-required --profile ACGCP > EKSAdmin-login-profile.json
    aws iam create-access-key --user-name EKSAdmin --profile ACGCP >> EKSAdmin-login-profile.json
5. configure awscli (using EKSAdmin):
    aws configure --profile EKS
    <EKS ACCESS ID>
    <EKS SECRET ACCESS KEY>
    us-east-1
    json
6. test:
    aws ec2 describe-vpcs --profile EKS
7. Set environment variable:
    $env:AWS_PROFILE="EKS"
8. Create EKS Cluster:
    eksctl create cluster --name=eksdemo1 --version 1.21 --region us-east-1 --zones=us-east-1a,us-east-1b,us-east-1c --nodegroup-name standard-workers --node-type t3a.medium --nodes 3 --nodes-min 1 --nodes-max 4 --managed
9. Verify:
    eksctl get cluster
    kubectl get nodes
10.Enable IAM OIDC Provider:
    eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster eksdemo1 --approve
11.Create EC2 key pair
    if (Test-Path kube-demo.pem)
    {
     remove-item kube-demo.pem -force
    }
    aws ec2 create-key-pair --key-name kube-demo --output text | out-file -encoding ascii -filepath kube-demo.pem
12.Create node group
    eksctl create nodegroup --cluster=eksdemo1 --region=us-east-1 --name=eksdemo1-ng-public1 --node-type=t3.medium --nodes=2 --nodes-min=2 --nodes-max=4 --node-volume-size=20 --ssh-access --ssh-public-key=kube-demo --managed --asg-access --external-dns-access --full-ecr-access --appmesh-access --alb-ingress-access 
13.Update security group
    $sg = aws ec2 describe-security-groups --filters Name=group-name,Values=*remote* --query "SecurityGroups[*].{ID:GroupId}" --profile EKS 
    $sg_id = ($sg.replace("[","").replace("]","") | jq ".ID").replace('"',"")
    aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol all --port -1 --cidr 0.0.0.0/0
14.Verify configuration
    eksctl get cluster
    eksctl get nodegroup --cluster=eksdemo1
    kubectl get nodes -o wide
    kubectl config view --minify
    
    
xx.Clean up:  
    eksctl get nodegroup --cluster=eksdemo1
    eksctl delete nodegroup --cluster=eksdemo1 --name=eksdemo1-ng-public1
    eksctl delete nodegroup --cluster=eksdemo1 --name=standard-workers
    eksctl delete cluster eksdemo1