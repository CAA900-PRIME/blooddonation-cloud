# Project Overview - Blood Donation Cloud Infrastrucutre
This web application is designed to simplify blood donation by directly connecting donors and requester without intermediaries. All users register under a single system, where they can act as both donors and requester. Once registered, users needing blood can submit a request, while donors simply wait to receive notifications about nearby requests.

The goal is to make the donation process faster and more efficient, reducing the time involved in finding a suitable donor. The platform prioritizes simplicity, ensuring a user-friendly experience with minimal steps.

### Topology
![](https://github.com/CAA900-PRIME/blooddonation-cloud/blob/main/terraform/digram.jpeg)

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) installed
- Cloud provider credentials set up (e.g., AWS, GCP, Azure)

## Init & Setup

First will have to clone this repository

>[!NOTE]
>For nginx setup instructions go [here](https://github.com/CAA900-PRIME/blooddonation-cloud/tree/main/nginx)

```bash
git clone git@github.com:CAA900-PRIME/blooddonation-cloud.git
```

>[!IMPORTANT]
>Please ensure:
>1. Install Azure CLI. [Windows](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?pivots=winget) and [macOS](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos)
>2. Configure Azure locally and ensure connectin to the azure api.
>3. Azure CLI [Documentation](https://learn.microsoft.com/en-us/cli/azure/)

Generate SSH key 
```bash
ssh-keygen -t rsa -b 4096 -f ./bd_key
```

Will also need to login to Azure using Azure CLI before using terraform. To login using azure cli:

```bash
az login
```

A web page will open in a new tab, must login manually. Next, will need to modify the subscription id within 

```terraform 
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "" # Must be provided
}
```

Change the working directory to `terrform/` 

```bash
cd terraform
```

Initialize and downloads provider plugins and sets up the backend for storing state.

```bash
terraform init
```

The following command shows what actions Terraform will take without applying

```bash
terraform plan
```

And to apply the changes required to reach the desired state defined in the configuration

```bash
terraform apply --auto-approve
```
Connect to Azure VM

```bash
ssh -i bd_key azureu@ip-address
```

After loging in, will start the following servers:
1. Running mysql through docker.
2. Running the backend
3. Running the frontend

Will ues [tmux](https://github.com/tmux/tmux/wiki) to manage and run all server processes in detached sessions, ensuring that they continue running even if the connection is lost.

##### Terraform list of commands:
1. `terraform init` Initialize terraform
2. `terraform plan` Show what its going to be built before applying the changes.
3. `terraform apply --auto-approve` Apply the changes to the cloud.
4. `terraform validate` validates the configuration files for syntax errors.
5. `terraform fmt` Formatting the file.
6. `terraform destroy` Destroyes all the resources managed by the current configuration.


Ansible Control Node (linux fully operated inside windows machine )

install Ansible 

```bash
sudo apt update
sudo apt install ansible -y
```

Execute the Ansible Playbook

```bash
ansible-playbook -i inventory.ini deploy_applications.yml
```

## Current plan

The objective is to deploy a virtual machine (VM) in the cloud, install Docker, and utilize Ansible to automate the deployment and management of services—such as the backend, frontend, and MySQL database—within Docker containers. This approach ensures a streamlined, consistent, and efficient deployment process.


Provision a Cloud VM:
Deploy a VM instance using your chosen cloud provider (e.g., AWS, Azure, GCP).

Install Docker on the VM:
Use Ansible to automate the installation of Docker on the VM.
Create an Ansible playbook that installs Docker and its dependencies.

Develop Docker Images for Services:
Create Dockerfiles for each service (backend, frontend, MySQL) defining their environments.
Build and test these images locally before deployment.

Push Docker Images to a Registry:
Push the built images to a container registry (e.g., Docker Hub, AWS ECR) for accessibility.

Create Ansible Playbooks for Deployment:
Develop playbooks to pull the Docker images from the registry and run them as containers on the VM.
Define tasks to manage container orchestration, networking, and environment variables.

Execute Ansible Playbooks:
Run the playbooks to automate the deployment of services within Docker containers on the VM.
Ensure proper sequencing and dependencies are managed.

Monitor and Maintain Services:
Implement monitoring solutions to track the health and performance of the services.
Use Ansible for ongoing configuration management and updates.
