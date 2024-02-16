# Learning Jenkins and EC2 suff

I created this repo learn about Jenkins and to get more comfortable useing EC2/traditonal servers.

## What the code here will do

The code in this repo will be able to do the following

- Build AMIs for Jenkins controller and builder
- Have a Jenkins pipeline that can:
  - Build docker images
  - Push images to a repo (ECR/Artifact Registry/dockerhub)
  - Deploy the image (Cloud run/EC2/ECS)
- Have a basic frontend app (React/next) that Jekins can build
- Have some Terraform code to deploy the nesseary service
- Have diagrams of architectur and build process

## My Goals

- [x] Build an AMI for the Jekins controller with Packer
- [x] Build an AMI for the Jenkins Docker Builder with Packer
- [] Store the Jenkins config outside of the AMI?
- [x] Add the template react/nextJS app
- [] Add jenkins pipeline that can build from this repo (GH scm polling)
  - [x] Frontend
  - [] Infra
  - [] Packer
- [] Set up infra with Terraform
  - [x] VPC, SG and routes
  - [x] Jenkins Controller
  - [x] Launch template and Autoscaling group for Builder instances
  - [x] IAM role for controller to start EC2 instances from Autoscaling group
  - [] Get ssh key and name of Autoscaling group to controller
- [] Create diagrams of infra
- [] Create diagram of build

## Stretch Goals

- [] Retrive secret from AWS or GCP inside Jenkins builds
- [] Trigger build from GH webhooks
  - Might need a proxy inbetween GH and Jenkins
  - Look at useing a lambda in the Jenkins VPC??
- [] Set up the pipeline so that terraform can not build unless packer has built at least once
- [] Add SSM to AMIs
- [] Add monitoring, maybe cloudwatch?
- [] Deploy the email project with this set up
- [] Delete old version of the AMI when a new one is built
- [] Multicloud deployment, Jenkins in AWS deploying to GCP
