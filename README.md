# Flask CRUD Application – AWS EKS DevOps Project

## Table of Contents

1. [Project Overview](#project-overview)
   - [Introduction](#introduction)
   - [Key Features](#key-features)

2. [Architecture Overview](#architecture-overview)
   - [High-Level Architecture](#high-level-flow)

3. [Infrastructure Components](#infrastructure-components)
   - [AWS Infrastructure](#1-aws-infrastructure)
   - [VPC Module](#vpc-module)
   - [EKS Module](#eks-module)
   - [RDS PostgreSQL](#rds-module)

4. [Application Layer](#application-layer)
   - [Flask CRUD Application](#flask-crud-application)
   - [Docker Containerization](#flask-crud-application)

5. [Kubernetes & Helm Deployment](#kubernetes--helm-deployment)
   - [Helm Chart](#kubernetes--helm-deployment)
   - [Application Namespace](#kubernetes--helm-deployment)
   - [Database Secret](#kubernetes--helm-deployment)
   - [Deployment Verification](#kubernetes--helm-deployment)

6. [CI Pipeline](#ci-pipeline)
   - [CI Workflow](#ci-workflow)
   - [Docker Image Build & Push](#ci-pipeline)
   - [Security Scanning](#security-gates)
   - [Trivy Security Report](#security-reporting)

7. [Continuous Deployment](#continuous-deployment)
   - [Terraform Infrastructure Deployment](#3-provision-aws-infrastructure)
   - [EKS Configuration](#6-configure-eks)
   - [Database Configuration](#7-configure-database-secret)
   - [Helm Application Deployment](#8-deploy-application)
   - [Deployment Verification](#9-verify-deployment)

8. [Monitoring & Observability](#monitoring--observability)
   - [Prometheus](#monitoring--observability)
   - [Grafana](#monitoring--observability)
   - [ServiceMonitor](#monitoring--observability)

9. [Security Implementation](#security-implementation)
   - [Container Security](#container-security)
   - [Python Dependency Security](#python-dependency-security)
   - [Infrastructure Security](#infrastructure-security)
   - [Helm Security](#helm-security)
   - [Secret Management](#secret-management)
   - [Security Reporting](#security-reporting)

10. [Repository Structure](#repository-structure)

11. [Technologies Used](#technologies-used)

12. [Key DevOps Workflow](#key-devops-workflow)

13. [Project Outcome](#project-outcome)

## Project Overview

### Introduction

This project demonstrates the deployment and automation of a containerized Flask CRUD application on AWS EKS, using modern DevOps practices for infrastructure provisioning, application deployment, security scanning, and monitoring.

The infrastructure is provisioned using Terraform, with reusable modules for VPC, EKS, and RDS PostgreSQL. The Flask application is containerized using Docker, published to Docker Hub, and deployed to Kubernetes using Helm.

The complete deployment workflow is automated through GitHub Actions, providing separate CI and CD workflows. The CI pipeline performs Docker image builds, vulnerability scanning, dependency auditing, and Infrastructure-as-Code security checks. The CD pipeline provisions the AWS infrastructure, retrieves the RDS connection details, configures the EKS cluster, deploys the application using Helm, and configures Prometheus and Grafana for Kubernetes monitoring.

### Key Features

- **Containerized Application:** Flask CRUD application packaged as a Docker image.
- **Infrastructure as Code:** AWS infrastructure provisioned and managed using modular Terraform.
- **Kubernetes Deployment:** Flask application deployed and managed on Amazon EKS.
- **Helm-Based Deployment:** Application configuration and Kubernetes resources packaged into a reusable Helm chart.
- **Managed Database:** PostgreSQL database hosted on Amazon RDS.
- **Automated CI/CD:** GitHub Actions automates image building, security validation, infrastructure provisioning, and application deployment.
- **Security Scanning:** Trivy scans container images, Terraform, Helm configurations, vulnerabilities, misconfigurations, and secrets.
- **Dependency Security:** `pip-audit` validates Python package dependencies inside the application container.
- **Monitoring:** Prometheus and Grafana deployed through the `kube-prometheus-stack`.
- **Security Reporting:** Trivy generates an HTML security dashboard that is uploaded as a GitHub Actions artifact.
- **Reusable Infrastructure:** Terraform modules separate VPC, EKS, and RDS infrastructure for maintainability.

---

# Architecture Overview

The project follows a cloud-native architecture where the application, infrastructure, deployment, security, and monitoring layers are separated.
<img width="2939" height="1716" alt="j9AZsl2pi2Zz4eUoEOa3f2om6Ez1qENfj3tVNCghZ2UUWnuCTuVNfRfmP6TpCjxXnqX2guPWtAXup4mtdRNnyzlRGgUXW6Hbay4WZAzpZZlgHJRAmnyCOqSpbtnaYLX3y8iPrO5VjfUZXZQaIidj3dFCFQNrE7s6ePWekTUWxg2Zem9drFvt72MFqUeg2u2l" src="https://github.com/user-attachments/assets/62e58ce5-da2c-47b6-b518-75f484b08fa2" />




### High-Level Flow

```text
                    Developer
                        |
                        v
                   GitHub Repo
                        |
             +----------+----------+
             |                     |
             v                     v
       CI Pipeline            CD Pipeline
       GitHub Actions         GitHub Actions
             |                     |
       +-----+------+       +------+------+
       |            |       |             |
    Docker       Security  Terraform    AWS Auth
     Build        Scans       |             |
       |            |         v             |
       |            |    AWS Infrastructure |
       |            |         |             |
       v            v         +------+------+ 
    Docker Hub              VPC / EKS / RDS
                                  |
                                  v
                           Amazon EKS Cluster
                                  |
                            Helm Deployment
                                  |
                                  v
                         Flask CRUD Application
                                  |
                                  v
                          Amazon RDS PostgreSQL
                                  |
                     +------------+------------+
                     |                         |
                     v                         v
                 Prometheus                Grafana
                 Monitoring               Dashboard
```

# Infrastructure Components

## 1. AWS Infrastructure

The AWS infrastructure is managed through Terraform and organized into reusable modules.

### VPC Module

The Terraform structure contains a dedicated VPC module responsible for the networking layer.

```text
terraform/
├── backend/
│   ├── vpc/
│   ├── main.tf
│   └── outputs.tf
│
└── modules/
    ├── vpc/
    ├── eks/
    └── rds/
```

This modular structure allows infrastructure components to be managed independently while keeping the overall deployment organized.

### EKS Module

The EKS module provisions the Kubernetes infrastructure required to run the Flask application.

The CD pipeline retrieves the EKS cluster configuration using:

```bash
aws eks update-kubeconfig   --name "${{ vars.EKS_CLUSTER_NAME }}"   --region us-east-1
```

This allows GitHub Actions to communicate with the Kubernetes cluster using `kubectl`.

### RDS Module

The project uses **Amazon RDS PostgreSQL** as the persistent database layer.

Terraform outputs are used by the deployment pipeline to retrieve:

```text
RDS Endpoint
Database Name
```

The connection information is then passed securely to Kubernetes through the `flask-db-secret`.

---

# Application Layer

## Flask CRUD Application

The backend application is developed using **Flask** and is containerized using Docker.

The Docker image is built from the Flask application directory:

```bash
docker build   -t $DOCKER_USER/flask-app:latest   flask-app/
```

The resulting image is pushed to Docker Hub:

```bash
docker push $DOCKER_USER/flask-app:latest
```

This creates a consistent application artifact that can be deployed across environments.

---

# Kubernetes & Helm Deployment

The Kubernetes deployment is managed using **Helm**.

The repository contains a dedicated Helm structure:

```text
flask-CRUD-infra/
└── helm/
    ├── flask-app/
    ├── flask-app-0.1.0.tgz
    ├── monitoring-values.yaml
    └── service-monitor.yaml
```

The deployment pipeline creates the application namespace:

```bash
kubectl create namespace flask-app   --dry-run=client -o yaml | kubectl apply -f -
```

The application is then deployed using:

```bash
helm upgrade --install flask-app   ./flask-CRUD-infra/helm/flask-app   --namespace flask-app
```

After deployment, Kubernetes rollout status is verified:

```bash
kubectl rollout status   deployment/flask-app   -n flask-app
```

This ensures that the pipeline doesn't simply submit Kubernetes resources—it also validates that the application successfully reaches its desired deployment state.

---

# CI Pipeline

The CI pipeline is triggered automatically whenever code is pushed to the `main` branch.

```yaml
on:
  push:
    branches:
      - main
```

### CI Workflow

```text
Git Push
   |
   v
GitHub Actions
   |
   v
Checkout Code
   |
   v
Docker Hub Login
   |
   v
Build Docker Image
   |
   v
Push Image to Docker Hub
   |
   +-----------------------+
   |                       |
   v                       v
Trivy Image Scan      pip-audit
   |                       |
   +-----------+-----------+
               |
               v
       Terraform Scan
               |
               v
         Helm Scan
               |
               v
      Full Trivy Scan
               |
               v
      HTML Security Report
               |
               v
       GitHub Artifact
```

### Security Gates

The pipeline performs Trivy scans against the Docker image and fails when **HIGH or CRITICAL** vulnerabilities are detected.

It also performs:

- OS package vulnerability scanning
- Python dependency auditing using `pip-audit`
- Terraform misconfiguration scanning
- Helm misconfiguration scanning
- Secret detection
- Filesystem vulnerability scanning

For example:

```bash
trivy image   --exit-code 1   --severity HIGH,CRITICAL   --ignore-unfixed   --pkg-types os   $DOCKER_USER/flask-app:latest
```

This introduces security validation directly into the CI process rather than waiting until deployment.

---

# Continuous Deployment

The CD pipeline is manually triggered using:

```yaml
on:
  workflow_dispatch:
```

The deployment process consists of the following stages:

### 1. Checkout Source Code

GitHub Actions checks out the repository.

### 2. Configure Terraform

Terraform `1.10.0` is installed and initialized.

```bash
terraform init -input=false
terraform validate
```

### 3. Provision AWS Infrastructure

The infrastructure is automatically applied:

```bash
terraform apply   -input=false   -auto-approve
```

This provisions or updates the AWS resources defined by the Terraform configuration.

### 4. Retrieve Database Information

Terraform outputs are used to obtain the RDS connection information:

```bash
terraform output -raw rds_endpoint
terraform output -raw rds_db_name
```

### 5. Build & Push Docker Image

The Flask application image is rebuilt and pushed to Docker Hub.

### 6. Configure EKS

The workflow updates the local kubeconfig:

```bash
aws eks update-kubeconfig   --name "$EKS_CLUSTER_NAME"   --region us-east-1
```

### 7. Configure Database Secret

The RDS connection string is stored in a Kubernetes Secret:

```text
flask-db-secret
```

The application can therefore obtain its database connection without hardcoding the database endpoint into the application source code.

### 8. Deploy Application

Helm performs the application deployment:

```bash
helm upgrade --install flask-app ...
```

### 9. Verify Deployment

The pipeline waits for the Kubernetes deployment to successfully roll out.

---

# Monitoring & Observability

The project implements Kubernetes monitoring using the **Prometheus + Grafana stack**.

The deployment uses the Prometheus Community Helm repository and installs:

```text
kube-prometheus-stack
```

The pipeline executes:

```bash
helm upgrade --install prometheus-stack   prometheus-community/kube-prometheus-stack   --namespace monitoring   --create-namespace
```

Custom configuration is provided through:

```text
monitoring-values.yaml
```

The project also contains:

```text
service-monitor.yaml
```

which is applied to configure application/service monitoring.

### Monitoring Architecture

```text
                    EKS Cluster
                        |
             +----------+----------+
             |                     |
             v                     v
       Flask Application       Kubernetes
             |                  Resources
             |                     |
             +----------+----------+
                        |
                        v
                   Prometheus
                        |
                        v
                    Grafana
                        |
                        v
                Monitoring Dashboard
```

This provides visibility into the Kubernetes environment and application-related metrics.

---

# Security Implementation

Security is incorporated throughout the development and deployment lifecycle.

### Container Security

Docker images are scanned using Trivy for HIGH and CRITICAL vulnerabilities.

### Python Dependency Security

The application container runs:

```bash
pip-audit
```

to identify vulnerable Python dependencies.

### Infrastructure Security

Terraform configurations are scanned using:

```bash
trivy fs --scanners misconfig
```

This helps identify infrastructure misconfigurations before deployment.

### Helm Security

Helm configuration is also scanned for Kubernetes-related misconfigurations.

### Secret Management

Sensitive values such as:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DOCKER_TOKEN
DB_PASSWORD
```

are supplied through GitHub Actions Secrets rather than being hardcoded into the workflow.

The database connection is subsequently created as a Kubernetes Secret.

### Security Reporting

A Trivy HTML report is generated:

```text
trivy-report.html
```

and uploaded as a GitHub Actions artifact with a seven-day retention period.

---

# Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── ci.yaml
│       └── ...
│
├── flask-app/
│   └── Flask Application
│
└── flask-CRUD-infra/
    │
    ├── helm/
    │   ├── flask-app/
    │   ├── flask-app-0.1.0.tgz
    │   ├── monitoring-values.yaml
    │   └── service-monitor.yaml
    │
    ├── k8s/
    │
    └── terraform/
        │
        ├── backend/
        │   ├── vpc/
        │   ├── .terraform.lock.hcl
        │   ├── main.tf
        │   └── outputs.tf
        │
        ├── modules/
        │   ├── eks/
        │   ├── rds/
        │   └── vpc/
        │
        ├── .terraform.lock.hcl
        ├── main.tf
        ├── terraform.tfvars
        └── variables.tf
```

---

# Technologies Used

| Category | Technologies |
|---|---|
| Application | Python, Flask |
| Containerization | Docker |
| Cloud | AWS |
| Kubernetes | Amazon EKS |
| Database | Amazon RDS PostgreSQL |
| Infrastructure as Code | Terraform |
| Package Management / Deployment | Helm |
| CI/CD | GitHub Actions |
| Container Registry | Docker Hub |
| Security | Trivy, pip-audit |
| Monitoring | Prometheus |
| Visualization | Grafana |
| Kubernetes CLI | kubectl |
| Source Control | Git/GitHub |

---

# Key DevOps Workflow

The overall implementation can be summarized as:

```text
                    ┌───────────────┐
                    │    Developer  │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │     GitHub    │
                    └───────┬───────┘
                            │
                    Push to main
                            │
                            ▼
                ┌───────────────────────┐
                │    GitHub Actions CI  │
                └───────────┬───────────┘
                            │
                  ┌─────────┴─────────┐
                  ▼                   ▼
            Docker Build        Security Scans
                  │                   │
                  ▼                   ▼
             Docker Hub       Trivy / pip-audit
                  │
                  ▼
          ┌─────────────────┐
          │ Terraform Apply │
          └────────┬────────┘
                   │
          ┌────────┼─────────┐
          ▼        ▼         ▼
         VPC      EKS       RDS
                   │        PostgreSQL
                   │
                   ▼
              Configure
              kubeconfig
                   │
                   ▼
                 Helm
                   │
                   ▼
          ┌─────────────────┐
          │  Flask App      │
          │   on EKS       │
          └────────┬────────┘
                   │
                   ▼
            RDS PostgreSQL

                   +

          ┌─────────────────┐
          │ Prometheus      │
          │       +         │
          │ Grafana         │
          └─────────────────┘
```

# Project Outcome

The project establishes an automated DevOps workflow for deploying a **Flask CRUD application to AWS EKS**. It combines **Terraform-based infrastructure provisioning, Docker containerization, GitHub Actions CI/CD, Helm-based Kubernetes deployment, RDS PostgreSQL, automated security scanning, and Prometheus/Grafana monitoring** into a single deployment process.

The main objective is to demonstrate how an application can move from **source code → secure container image → provisioned AWS infrastructure → Kubernetes deployment → monitored workload** using repeatable and automated DevOps practices.

⭐ Support the Project
If you found this project helpful, please consider:

Starring ⭐ the repository
Sharing it with your network
Contributing to its improvement

🛠️ Author & Community
This project is maintained by Harshhaa 💡. Your feedback and contributions are welcome!

📧 Connect with me:

GitHub: [nikhilsalammain-git](https://github.com/nikhilsalammain-git)
LinkedIn: [Nikhil Salam](https://www.linkedin.com/in/nikhil-salam/)



