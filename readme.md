exemplo
name: Terraform, Azure CLI, and Annotations Workflow

on:
  push:
    branches:
      - main
    paths:
      - contoso-01/**

  pull_request:
    paths:
      - contoso-01/**

permissions:
  contents: read
  id-token: write

jobs:
  terraform-dev:
    name: 'terraform-dev'
    runs-on: ubuntu-latest
    environment: development
    env:
      TF_WORKSPACE: ${{ secrets.TF_WORKSPACE_DEV }}
      PATH_TO_MODULE: contoso-01

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure Git Credentials
        run: |
          git config --global url."https://${{ secrets.REPO_TOKEN }}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
      
      - name: Install Azure CLI
        run: |
          sudo apt-get update
          sudo apt-get install -y azure-cli
          
      - name: Azure CLI Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID_DEV }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID_DEV }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

      - name: Terraform Init
        run: |
          cd $PATH_TO_MODULE
          terraform init -var-file="terraform.tfvars"
      
      - name: Terraform Plan
        run: |
          cd $PATH_TO_MODULE
          terraform plan -var-file="terraform.tfvars" -var="client_id=${{ secrets.AZURE_CLIENT_ID_DEV }}" -var="environment=${{ secrets.ENVIRONMENT_DEV }}"
      
      - name: Terraform Apply
        run: |
          cd $PATH_TO_MODULE
          terraform apply -var-file="terraform.tfvars" -var="client_id=${{ secrets.AZURE_CLIENT_ID_DEV }}" -var="environment=${{ secrets.ENVIRONMENT_DEV }}" -auto-approve

  manual-approval-destroy-dev:
    name: Manual Approval
    runs-on: ubuntu-latest
    needs: terraform-dev
    if: success()
    permissions:
      issues: write

    steps:
      - name: Await Manual Approval
        uses: trstringer/manual-approval@v1
        with:
          secret: ${{ github.TOKEN }}
          approvers: rafaveloso23
          minimum-approvals: 1
          issue-title: "Manual Approval Required for Terraform Destroy"
          issue-body: "Please approve or deny the deployment."

  terraform-destroy-dev:
    name: 'terraform-destroy-dev'
    runs-on: ubuntu-latest
    needs: manual-approval-destroy-dev
    environment: development
    env:
      TF_WORKSPACE: ${{ secrets.TF_WORKSPACE_DEV }}
      PATH_TO_MODULE: contoso-01

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure Git Credentials
        run: |
          git config --global url."https://${{ secrets.REPO_TOKEN }}:x-oauth-basic@github.com/".insteadOf "https://github.com/"
          
      - name: Install Azure CLI
        run: |
          sudo apt-get update
          sudo apt-get install -y azure-cli
          
      - name: Azure CLI Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID_DEV }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID_DEV }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

      - name: Terraform Init
        run: |
          cd $PATH_TO_MODULE
          terraform init -var-file="terraform.tfvars"
      
      - name: Terraform Destroy
        run: |
          cd $PATH_TO_MODULE
          terraform destroy -var-file="terraform.tfvars" -var="client_id=${{ secrets.AZURE_CLIENT_ID_DEV }}" -var="environment=${{ secrets.ENVIRONMENT_DEV }}" -auto-approve