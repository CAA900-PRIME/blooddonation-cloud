# Project Overview - Blood Donation Cloud Infrastrucutre
This web application is designed to simplify blood donation by directly connecting donors and requester without intermediaries. All users register under a single system, where they can act as both donors and requester. Once registered, users needing blood can submit a request, while donors simply wait to receive notifications about nearby requests.

The goal is to make the donation process faster and more efficient, reducing the time involved in finding a suitable donor. The platform prioritizes simplicity, ensuring a user-friendly experience with minimal steps.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) installed
- Cloud provider credentials set up (e.g., AWS, GCP, Azure)

## Init & Setup

First will have to clone this repository

```bash
git clone git@github.com:CAA900-PRIME/blooddonation-cloud.git
```

>[!IMPORTANT]
>Please ensure:
>1. Install Azure CLI. [Windows](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?pivots=winget) and [macOS](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos)
>2. Configure Azure locally and ensure connectin to the azure api.
>3. Azure CLI [Documentation](https://learn.microsoft.com/en-us/cli/azure/)

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

Here are other terraform list of commands:
1. `terraform validate` validates the configuration files for syntax errors.
2. `terraform fmt` Formatting the file.
3. `terraform destroy` Destroyes all the resources managed by the current configuration.

## Current plan

The goal is to deploy a virtual machine in the cloud, install Docker, and run all services—such as the backend, frontend, and MySQL database—in containers.

An alternative solution is to use multiple virtual machines, each running a separate service, but this approach would be overkill.
