# Azure Flask App

A Flask web application deployed to Azure App Service, provisioned with Terraform, and continuously deployed via GitHub Actions. Built as a portfolio project to demonstrate cloud engineering skills.

---

## Architecture

```
GitHub Repository
│
├── GitHub Actions (CI/CD)
│   ├── Run pytest tests
│   └── Zip deploy to Azure App Service
│
└── infra/ (Terraform)
    ├── Resource Group
    ├── App Service Plan (Linux, F1)
    └── Linux Web App
         └── flask-app-robbie321.azurewebsites.net

Terraform State
└── Azure Blob Storage (tfstaterobbie321 / tfstate container)
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Application | Python / Flask |
| Infrastructure | Terraform (azurerm ~3.0) |
| Hosting | Azure App Service (Linux, F1 free tier) |
| CI/CD | GitHub Actions |
| State backend | Azure Blob Storage |
| Development | GitHub Codespaces |

---

## Project Structure

```
azure-flask-app/
├── app.py                        # Flask application
├── requirements.txt              # Python dependencies
├── test_app.py                   # pytest test suite
├── .github/
│   └── workflows/
│       └── deploy.yml            # GitHub Actions pipeline
└── infra/
    ├── main.tf                   # Terraform resources + remote backend
    ├── outputs.tf                # App URL output
    └── variables.tf
```

---

## CI/CD Pipeline

Every push to `main` triggers the following pipeline:

1. **Checkout** — pull latest code
2. **Set up Python 3.11**
3. **Install dependencies** — `pip install -r requirements.txt`
4. **Run tests** — `pytest test_app.py -v` (deploy blocked if tests fail)
5. **Zip app** — package application files
6. **Deploy** — zip deploy to Azure App Service via publish profile

---

## Infrastructure

All Azure resources are provisioned with Terraform.

**Resources:**

- `azurerm_resource_group` — `flask-app-rg` (North Europe)
- `azurerm_service_plan` — Linux, F1 free tier
- `azurerm_linux_web_app` — Python 3.11 runtime, gunicorn startup

**Remote state** is stored in Azure Blob Storage (`tfstaterobbie321` storage account, `tfstate` container) so state is not local to any machine or Codespace.

---

## How to Deploy

### Prerequisites

- Azure subscription
- Terraform installed
- Azure CLI installed and authenticated

### 1. Clone the repo

```bash
git clone https://github.com/robbie321/azure-flask-app.git
cd azure-flask-app
```

### 2. Provision infrastructure

```bash
cd infra
terraform init
terraform apply
```

### 3. Set GitHub secret

Get the App Service publish profile:

```bash
az webapp deployment list-publishing-profiles \
  --resource-group flask-app-rg \
  --name flask-app-robbie321 \
  --xml
```

Add the output as a repository secret named `AZURE_WEBAPP_PUBLISH_PROFILE` in:
**GitHub → Settings → Secrets and variables → Actions**

### 4. Push to deploy

Any push to `main` will trigger the GitHub Actions pipeline and deploy the app automatically.

---

## Running Locally

```bash
pip install -r requirements.txt
flask run
```

App runs at `http://localhost:5000`

---

## Running Tests

```bash
pip install pytest
pytest test_app.py -v
```

---

## Live URL

[https://flask-app-robbie321.azurewebsites.net](https://flask-app-robbie321.azurewebsites.net)

---

## Roadmap

- [ ] Azure Key Vault for secret management
- [ ] PostgreSQL database (Azure Database for PostgreSQL)
- [ ] Staging slot for blue/green deployments
- [ ] Terraform modules for reusability