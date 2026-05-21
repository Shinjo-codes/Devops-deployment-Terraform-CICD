# 🚀 End-to-End DevOps Deployment
## Docker + Terraform + CI/CD + Custom Domain + HTTPS

> **Project Overview:** A production-grade DevOps pipeline that containerizes a PHP application, provisions Azure infrastructure via Terraform, automates deployment with GitHub Actions, and serves it securely over a custom domain with HTTPS.

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Step 1: PHP Application Setup](#step-1-php-application-setup)
5. [Step 2: Docker Containerization](#step-2-docker-containerization)
6. [Step 3: GitHub Repository Setup](#step-3-github-repository-setup)
7. [Step 4: Terraform Infrastructure (IaC)](#step-4-terraform-infrastructure-iac)
8. [Step 5: GitHub Actions CI/CD Pipeline](#step-5-github-actions-cicd-pipeline)
9. [Step 6: Manual Deployment Verification](#step-6-manual-deployment-verification)
10. [Step 7: DNS Configuration](#step-7-dns-configuration)
11. [Step 8: SSL/HTTPS with Certbot](#step-8-sslhttps-with-certbot)
12. [Step 9: Nginx Reverse Proxy (Port Conflict Resolution)](#step-9-nginx-reverse-proxy-port-conflict-resolution)
13. [Common Issues & Resolutions](#common-issues--resolutions)
14. [Cleanup & Cost Management](#cleanup--cost-management)
15. [Key Takeaways](#key-takeaways)

---

## 🏗️ Architecture Overview

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   GitHub    │────▶│  GitHub Actions │────▶│  SSH into   │────▶│ Docker Build │────▶│  Linux VM   │
│   (Code)    │     │   (CI/CD)       │     │  Azure VM   │     │  & Run       │     │(Apache/PHP) │
└─────────────┘     └─────────────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
                                                                                           │
                                                                                           ▼
┌─────────────┐     ┌─────────────────────────────────────────────────────────────────────────────┐
│  End Users  │◀────│  Custom Domain (A Record) ◀── Public IP ◀── Azure Infrastructure (Terraform)│
│  (Browser)  │     │  + HTTPS (Certbot)                                                          │
└─────────────┘     └─────────────────────────────────────────────────────────────────────────────┘
```

### Infrastructure Provisioned by Terraform
```
Terraform → Resource Group → Virtual Network → Subnet → Network Security Group → Public IP → Linux VM
                                                                  │
                                                                  ▼
                                                        Ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3000 (Docker)
```

### Technologies Used
| Technology | Purpose |
|------------|---------|
| **GitHub** | Source code repository |
| **GitHub Actions** | CI/CD automation |
| **Docker** | Application containerization |
| **Terraform** | Infrastructure as Code (IaC) |
| **Azure** | Cloud infrastructure |
| **Apache + PHP** | Web server & runtime |
| **Linux (Ubuntu)** | Operating system |
| **Nginx** | Reverse proxy & SSL termination |
| **Certbot/Let's Encrypt** | Free SSL certificates |
| **DNS** | Custom domain routing |

---

## ✅ Prerequisites

Before starting, ensure you have:

- [ ] **Azure Account** — [Create one free](https://azure.microsoft.com/free/)
- [ ] **GitHub Account** — [Sign up](https://github.com/join)
- [ ] **Terraform** installed locally — [Download](https://developer.hashicorp.com/terraform/downloads)
- [ ] **Docker** installed locally — [Download](https://docs.docker.com/get-docker/)
- [ ] **Azure CLI** installed — [Download](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [ ] **SSH Key Pair** generated (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`)
- [ ] **Custom Domain** registered (e.g., from Namecheap, GoDaddy, etc.)

> 💡 **Generate SSH Key:**
> ```bash
> ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
> ```
> Press Enter to accept defaults. This creates `~/.ssh/id_rsa` (private) and `~/.ssh/id_rsa.pub` (public).

---

## 📁 Project Structure

```
devops-deployment-Terraform-CICD/
│
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
│
├── charitize/                  # PHP Application + Dockerfile
│   ├── index.php
│   ├── about.php
│   ├── contact.php
│   ├── donation.php
│   ├── Dockerfile
│   ├── css/
│   ├── img/
│   ├── js/
│   └── ...
│
├── terra4m/
│   └── main.tf                 # Infrastructure as Code
│
└── .gitignore                  # Ignore sensitive/cache files
```

---

## 📝 Step 1: PHP Application Setup

### 1.1 Download the PHP Application

Download the existing PHP application (Charitize — a charity organization website template) from the provided Google Drive link.

> 📸 ![Google Drive Download](screenshots/01-google-drive-download.png) 

### 1.2 Extract the ZIP File

Extract the downloaded ZIP file to your project workspace.

### 1.3 Organize Project Files

Place the extracted PHP files inside a `charitize/` folder. This folder will contain all your application code and the Dockerfile.

---

## 🐳 Step 2: Docker Containerization

### 2.1 Create the Dockerfile

Inside the `charitize/` folder, create a `Dockerfile` with the following content:

```dockerfile
# Use official PHP image with Apache
FROM php:8.2-apache

# Set working directory inside container
WORKDIR /var/www/html

# Copy application files into container
COPY . /var/www/html

# Expose port 80
EXPOSE 80

# Apache runs automatically in this base image
```

### 2.2 Dockerfile Explanation

| Instruction | Purpose |
|-------------|---------|
| `FROM php:8.2-apache` | Base image with PHP 8.2 and Apache pre-installed |
| `WORKDIR /var/www/html` | Sets the working directory (Apache's default document root) |
| `COPY . /var/www/html` | Copies all PHP files from host to container |
| `EXPOSE 80` | Opens port 80 for HTTP traffic |

> 📸 **!(screenshots/03-dockerfile-vscode.png): [VS Code Explorer showing the Dockerfile inside the charitize folder, with Dockerfile content visible]**

---

## 🐙 Step 3: GitHub Repository Setup

### 3.1 Create a New Repository

1. Go to [GitHub](https://github.com) and click **New Repository**
2. Name it: `devops-deployment`
3. Choose **Public** or **Private**
4. Click **Create repository**

### 3.2 Initialize and Push Local Repository

```bash
# Navigate to your project folder
cd devops-deployment

# Initialize Git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: PHP app + Dockerfile + Terraform"

# Add remote origin
git remote add origin https://github.com/YOUR_USERNAME/devops-deployment.git

# Rename branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

> 📸 **!(screenshots/04-github-new-repo.png)[INSERT SCREENSHOT: Terminal showing successful git push output with "branch 'main' set up to track 'origin/main'"]**

---

## 🏗️ Step 4: Terraform Infrastructure (IaC)

### 4.1 Create `main.tf`

Inside the `terraform/` folder, create `main.tf`:

```hcl
provider "azurerm" {
  features {}
}

# =========================================
# Resource Group
# =========================================
resource "azurerm_resource_group" "rg" {
  name     = "rg-php-devops"
  location = "West Europe"  # Change to your preferred region
}

# =========================================
# Virtual Network
# =========================================
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-php"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-php"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# =========================================
# Network Security Group
# =========================================
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-php"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # SSH Rule
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTP Rule
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTPS Rule
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Docker Application Port
  security_rule {
    name                       = "AllowDocker"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =========================================
# Public IP
# =========================================
resource "azurerm_public_ip" "pip" {
  name                = "php-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# =========================================
# Network Interface
# =========================================
resource "azurerm_network_interface" "nic" {
  name                = "php-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Attach NSG to NIC
resource "azurerm_network_interface_security_group_association" "assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# =========================================
# Linux Virtual Machine
# =========================================
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "php-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"  # Cost-effective tier
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  depends_on = [
    azurerm_network_interface_security_group_association.assoc
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/azure_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Custom data to install Docker on first boot
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker azureuser
  EOF
  )
}

# Output the Public IP
output "public_ip_address" {
  value = azurerm_public_ip.pip.ip_address
}
```

### 4.2 Terraform Resources Explained

| Resource | Purpose |
|----------|---------|
| `azurerm_resource_group` | Logical container for all Azure resources |
| `azurerm_virtual_network` | Private network with IP range 10.0.0.0/16 |
| `azurerm_subnet` | Subdivision of VNet for the VM |
| `azurerm_network_security_group` | Firewall rules (SSH, HTTP, HTTPS, Docker) |
| `azurerm_public_ip` | Static public IP for internet access |
| `azurerm_network_interface` | Network adapter connecting VM to VNet |
| `azurerm_linux_virtual_machine` | Ubuntu 22.04 VM with Docker pre-installed |

> 📸 **!(screenshots/06-terraform-main-tf.png)[INSERT SCREENSHOT: VS Code showing the terraform/main.tf file with syntax highlighting]**

### 4.3 Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply

# Note the Public IP output — you'll need it for DNS and GitHub Secrets
```
📸 **!(screenshots/07-terraform-main-tf.png)[INSERT SCREENSHOT: VS Code showing the terraform/main.tf terminal file with syntax highlighting]**

---

## ⚙️ Step 5: GitHub Actions CI/CD Pipeline

### 5.1 Create Workflow File

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy PHP App to Azure VM

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      # Step 1: Checkout code
      - name: Checkout repository
        uses: actions/checkout@v4

      # Step 2: Deploy to VM via SSH
      - name: Deploy to Azure VM
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.VM_HOST }}
          username: ${{ secrets.VM_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            # Remove old deployment
            rm -rf devops-deployment

            # Clone latest code
            git clone https://github.com/YOUR_USERNAME/devops-deployment.git

            # Navigate to app directory
            cd devops-deployment/charitize

            # Build Docker image
            docker build -t php-app .

            # Stop and remove old container (ignore errors if not running)
            docker stop php-app || true
            docker rm php-app || true

            # Run new container
            docker run -d -p 3000:80 --name php-app php-app
```

> ⚠️ **Important:** Replace `YOUR_USERNAME` with your actual GitHub username on line 23.

### 5.2 Workflow Breakdown

| Step | Action | Purpose |
|------|--------|---------|
| **Trigger** | `on: push: branches: [main]` | Auto-deploys on every push to main |
| **Checkout** | `actions/checkout@v4` | Pulls latest code into runner |
| **SSH Deploy** | `appleboy/ssh-action` | Connects to VM and runs deploy commands |
| **Cleanup** | `rm -rf devops-deployment` | Removes old code to prevent conflicts |
| **Clone** | `git clone ...` | Fetches fresh code from GitHub |
| **Build** | `docker build -t php-app .` | Creates new Docker image |
| **Stop/Remove** | `docker stop/rm` | Gracefully replaces old container |
| **Run** | `docker run -d -p 3000:80` | Starts container on port 3000 |

> 📸 **!(screenshots/08-github-secrets-vm-host.png)[INSERT SCREENSHOT: VS Code showing the .github/workflows/deploy.yml file]**

### 5.3 Configure GitHub Secrets

Navigate to your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

Add these three secrets:

| Secret Name | Value | How to Get It |
|-------------|-------|---------------|
| `VM_HOST` | Your VM's Public IP | Output from `terraform apply` or Azure Portal |
| `VM_USER` | `azureuser` | The admin username set in Terraform |
| `SSH_PRIVATE_KEY` | Contents of `~/.ssh/azure_key` | Run `cat ~/.ssh/azure_key` and copy the entire output |

> 📸 **!(screenshots/10-github-secrets-ssh-key.png)[INSERT SCREENSHOT: Terminal showing `cat ~/.ssh/azure_key` output and GitHub Secrets page showing SSH_PRIVATE_KEY being added]**

> ⚠️ **Critical:** Paste the **PRIVATE KEY** (starts with `-----BEGIN OPENSSH PRIVATE KEY-----`), NOT the public key!

---

## 🔍 Step 6: Manual Deployment Verification

Before relying on CI/CD, manually verify the VM and deployment work.

### 6.1 SSH into the VM

```bash
ssh azureuser@<YOUR_VM_PUBLIC_IP>
```
> 📸 **!(screenshots/11-ssh-vm.png)[INSERT SCREENSHOT: Terminal showing `ssh azureuser@<Your_VM_Public_IP>` output ]**

### 6.2 Clone and Deploy Manually

```bash
# Clone repository
sudo git clone https://github.com/YOUR_USERNAME/devops-deployment.git

# Navigate to app
cd devops-deployment/charitize

# Build and run Docker container
docker build -t php-app .
docker run -d -p 80:80 --name php-app php-app
```

### 6.3 Verify in Browser

Open your browser and visit:

```
http://<YOUR_VM_PUBLIC_IP>
```

You should see the Charitize PHP application running.

> 📸 **!(screenshots/11-manual-deploy-browser.png)[INSERT SCREENSHOT: Browser showing the Charitize website loaded via VM Public IP]**

---

## 🌐 Step 7: DNS Configuration

### 7.1 Add A Record

In your domain registrar's DNS management panel:

| Field | Value |
|-------|-------|
| **Type** | A |
| **Host** | app (or @ for root) |
| **Value** | Your VM Public IP Address |
| **TTL** | 14400 (or default) |

Example: `app.yourdomain.com` → `20.61.185.188`

> 📸 **!(screenshots/12-dns-a-record.png)[INSERT SCREENSHOT: DNS management panel showing A record configuration with Host: app, Type: A, Value: VM Public IP]**

### 7.2 DNS Propagation

DNS changes can take **5 minutes to 48 hours** to propagate globally. Use [whatsmydns.net](https://whatsmydns.net) to check.

---

## 🔒 Step 8: SSL/HTTPS with Certbot

### 8.1 Install Certbot and Nginx

```bash
# SSH into VM
ssh azureuser@<YOUR_VM_PUBLIC_IP>

# Update packages
sudo apt update

# Install Nginx and Certbot
sudo apt install -y nginx certbot python3-certbot-nginx
```

### 8.2 Obtain SSL Certificate

```bash
sudo certbot --nginx -d app.yourdomain.com
```

Follow the prompts:
1. Enter your email address
2. Agree to Terms of Service
3. Choose whether to share your email with EFF
4. Certbot will automatically configure Nginx

### 8.3 Verify HTTPS

Visit `https://app.yourdomain.com` — you should see a secure lock icon 🔒

> 📸 **!(screenshots/16-final-https-site.png)[INSERT SCREENSHOT: Browser showing the Charitize website with HTTPS lock icon in the address bar]**


### 8.4 Auto-Renewal

Certbot sets up automatic renewal. Verify with:

```bash
sudo certbot renew --dry-run
```

---

## 🔄 Step 9: Nginx Reverse Proxy (Port Conflict Resolution)

### The Problem

By default, both Nginx (for Certbot/SSL) and your Docker container want to use **port 80**. This causes conflicts. The solution is to:

1. Run Docker on **port 3000**
2. Configure Nginx to **reverse proxy** traffic from port 80 → port 3000

### 9.1 Update Docker Run Command

Your CI/CD pipeline already maps port **3000**:

```bash
docker run -d -p 3000:80 --name php-app php-app
```

### 9.2 Configure Nginx as Reverse Proxy

```bash
# Edit Nginx default site
sudo nano /etc/nginx/sites-available/default
```

Add this `location` block inside the `server` block:

```nginx
server {
    listen 80;
    server_name app.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 9.3 Restart Nginx

```bash
sudo nginx -t          # Test configuration
sudo systemctl restart nginx
```

### 9.4 Allow Port 3000 in NSG

In Azure Portal, add an inbound security rule:

| Setting | Value |
|---------|-------|
| Source | Any |
| Source port ranges | * |
| Destination | Any |
| Service | Custom |
| Destination port ranges | 3000 |
| Protocol | TCP |
| Action | Allow |
| Priority | 1013 |
| Name | AllowDocker |

> 📸 **!(screenshots/15-azure-nsg-port-3000.png)[INSERT SCREENSHOT: Azure Portal NSG inbound security rules showing AllowDocker rule for port 3000]**

### 9.5 Verify End-to-End

Visit `https://app.yourdomain.com` — the flow is now:

```
User → HTTPS (443) → Nginx (80) → Proxy Pass → Docker (3000) → PHP App
```

> 📸 **!(screenshots/16-final-https-site.png)[INSERT SCREENSHOT: Browser showing the fully functional Charitize website via HTTPS custom domain]**

---

## 🐛 Common Issues & Resolutions

### ❌ Issue 1: Terraform Files Too Large for GitHub

**Symptom:** Git push fails or takes forever because `.terraform/` folder and `.tfstate` files are huge.

**Root Cause:** Terraform provider plugins and state files should not be committed.

**Resolution:** Create a `.gitignore` file:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log

# Sensitive files
*.pem
*.key

# OS files
.DS_Store
Thumbs.db
```

---

### ❌ Issue 2: "Can't Connect Without a Private SSH Key or Password"

**Symptom:** GitHub Actions fails at the SSH step with authentication errors.

**Root Cause:** The `SSH_PRIVATE_KEY` secret contains the **public key** instead of the **private key**.

**Resolution:**
- **Wrong:** `ssh-rsa AAAAB3...` (public key, one line)
- **Right:** `-----BEGIN OPENSSH PRIVATE KEY-----` (private key, multiple lines)

> 📸 **!(screenshots/20-permission-denied-log.png)[INSERT SCREENSHOT: GitHub Actions error log showing "can't connect without a private SSH key or password"]**

Run this to get the correct private key:
```bash
cat ~/.ssh/azure_key
```

---

### ❌ Issue 3: CI/CD Success but VM Doesn't Update

**Symptom:** GitHub Actions shows green checkmarks, but the website doesn't reflect new changes.

**Root Cause:** Permission denied errors during `rm -rf devops-deployment` because the folder was created with `sudo` during manual testing.

**Resolution:** Ensure the GitHub Actions script handles permissions:

```yaml
script: |
  sudo rm -rf devops-deployment || true
  git clone https://github.com/YOUR_USERNAME/devops-deployment.git
  cd devops-deployment/charitize
  docker build -t php-app .
  docker stop php-app || true
  docker rm php-app || true
  docker run -d -p 3000:80 --name php-app php-app
```


> 📸 **!(screenshots/21-successful-deploy-log.png)[INSERT SCREENSHOT: GitHub Actions log showing successful deployment after fix]**

---

### ❌ Issue 4: Port Conflicts — Nginx vs Docker

**Symptom:** Docker container stops, or Nginx fails to start. "Address already in use" errors.

**Root Cause:** Both services trying to bind to port 80.

**Resolution:** Use Nginx reverse proxy to forward port 80 → 3000, and run Docker on port 3000.


---

## 🧹 Cleanup & Cost Management

To avoid unexpected Azure charges, destroy resources when not needed:

```bash
cd terraform

# Destroy all infrastructure
terraform destroy

# Or delete the resource group via Azure CLI
az group delete -n rg-php-devops -y

# Also delete NetworkWatcherRG if created automatically
az group delete -n NetworkWatcherRG -y
```

> 📸 **!(screenshots/terraform-destroy.png)[INSERT SCREENSHOT: Terminal showing `terraform destroy` or `az group delete` command execution]**

---

## 🎯 Key Takeaways

| Concept | Lesson Learned |
|---------|---------------|
| **Containerization** | Docker ensures consistency across dev, staging, and production |
| **IaC** | Terraform makes infrastructure reproducible and version-controlled |
| **CI/CD** | GitHub Actions eliminates manual deployment errors |
| **Security** | SSH keys, NSG rules, and HTTPS are non-negotiable for production |
| **Reverse Proxy** | Nginx solves port conflicts and enables SSL termination |
| **DNS** | A records bridge custom domains to cloud infrastructure |
| **Troubleshooting** | Logs are your best friend — check GitHub Actions logs, Docker logs, and Nginx error logs |

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Certbot Instructions](https://certbot.eff.org/instructions)
- [Nginx Reverse Proxy Guide](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

---

## 👨‍💻 Author: Shina Ojo

**DevOps Engineer / Tutor**

> 🎓 *This project was completed as part of a hands-on DevOps bootcamp, demonstrating real-world deployment patterns used in production environments.*

---

## 📄 License

This project is for educational and documentation purposes. The Charitize template is used as a sample PHP application for demonstration.

---

*⭐ If you found this guide helpful, consider starring the repository and sharing it with others learning DevOps!*
