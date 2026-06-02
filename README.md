# 🎯 SkillPulse — Production-Grade AWS ECS DevOps Platform

[![AWS Fargate](https://img.shields.io/badge/AWS-ECS%20Fargate-orange?style=for-the-badge&logo=amazon-aws)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-blue?style=for-the-badge&logo=docker)](https://www.docker.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-black?style=for-the-badge&logo=github-actions)](https://github.com/features/actions)
[![Nginx](https://img.shields.io/badge/Nginx-Reverse%20Proxy-green?style=for-the-badge&logo=nginx)](https://www.nginx.com/)
[![MySQL](https://img.shields.io/badge/MySQL-RDS-blue?style=for-the-badge&logo=mysql)](https://aws.amazon.com/rds/)
[![SSL](https://img.shields.io/badge/SSL-AWS%20ACM-brightgreen?style=for-the-badge&logo=amazon-aws)](https://aws.amazon.com/certificate-manager/)
[![HTTPS](https://img.shields.io/badge/HTTPS-Live-success?style=for-the-badge&logo=letsencrypt)](https://skillpulse.altamash.cloud)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](https://opensource.org/licenses/MIT)

### 🌍 Live Deployment

> **[https://skillpulse.altamash.cloud](https://skillpulse.altamash.cloud)**
> Secured with AWS ACM SSL Certificate · Custom domain via CNAME routing to ALB

## 📌 Overview

Modern organizations require scalable, secure, and automated deployment platforms to deliver applications efficiently. **SkillPulse** is a cloud-native web application designed and deployed using a production-style cloud infrastructure on AWS and DevOps best practices.

This project simulates how real-world applications are deployed in enterprise environments, focusing on private networking patterns, container orchestration, automated CI/CD pipelines, runtime secrets management, and centralized monitoring.

---

## 🏗️ Architecture Design

Rather than deploying all resources publicly, the infrastructure was designed using a **layered security model** to restrict the blast radius and enforce network isolation.

```text
              [ Browser: https://skillpulse.altamash.cloud ]
                                │
                    DNS CNAME Record (Port 443)
                                │
                                ▼
                   ┌────────────────────────┐
                   │  AWS ACM SSL Certificate│
                   │  (TLS Termination)      │
                   └───────────┬────────────┘
                               │
                               ▼
         ┌──────────────────────────────────────────────┐
         │    Application Load Balancer (ALB)           │
         │    Listener: 443 (HTTPS) + 80→443 Redirect  │
         └──────────────┬────────────────┬──────────────┘
                        │                │
          Path: /       │                │   Path: /api/*
                        ▼                ▼
         ┌───────────────────┐    ┌───────────────────┐
         │   Frontend ECS    │    │    Backend ECS    │
         │  Service (Nginx)  │    │   Service (Go)    │
         └───────────────────┘    └─────────┬─────────┘
                                            │
                                            ▼
                                  ┌───────────────────┐
                                  │ Amazon RDS MySQL  │
                                  │    (Isolated)     │
                                  └───────────────────┘
```

> 📸 **Architecture HLD Map**

<img width="1747" height="982" alt="ECS_final_CI_CD_Architecture" src="https://github.com/user-attachments/assets/438bf49f-fa46-43da-a31e-522f0276c067" />


### 🏢 Layer Breakdown

- **Public Layer:** Contains only internet-facing resources — the Application Load Balancer (ALB), NAT Gateway, and Internet Gateway. These handle incoming and outgoing internet traffic while shielding internal services.
- **Private Application Layer:** Core compute workloads run in private subnets via AWS ECS Fargate. The Frontend and Backend containers are completely inaccessible directly from the internet and receive traffic exclusively through the ALB.
- **Private Database Layer:** The Amazon RDS MySQL database resides in isolated private database subnets. Only backend compute services are permitted to communicate with the database, significantly reducing the attack surface.

---

## 🛠️ Infrastructure Configuration Matrix

### 🌐 Networking & Compute

| Component | Configuration Pattern | Purpose / Core Features |
|---|---|---|
| **VPC** | Custom VPC Setup | Multi-AZ architecture spanning isolated tiers |
| **Subnets** | 2 Public, 2 Private App, 2 Private DB | Ensures high availability across distinct Availability Zones |
| **Gateways** | 1 Internet Gateway, 1 NAT Gateway | Manages secure public ingress and outbound private transitions |
| **ECS Launch Type** | AWS Fargate (Serverless) | Eliminates underlying EC2 host management overhead |
| **Container Registry** | Amazon ECR | Secure, highly available container image management |
| **Custom Domain** | `skillpulse.altamash.cloud` | CNAME record pointing to ALB DNS name |
| **SSL Certificate** | AWS ACM (TLS 1.2/1.3) | Free managed certificate; auto-renewed, attached to ALB HTTPS listener |

### 🔒 Security, Storage & Observability

| Component | Configuration Pattern | Purpose / Core Features |
|---|---|---|
| **Database Engine** | Amazon RDS MySQL | Situated strictly inside isolated database subnets |
| **Database Access** | Restricted Security Groups | Whitelists ingress on Port 3306 exclusively from Backend ECS tasks |
| **Secrets Engine** | AWS Secrets Manager | Secure storage; eliminates hardcoded variables at runtime |
| **Access Control** | IAM Roles (Least Privilege) | Granular execution roles for safe resource interaction |
| **Monitoring** | Amazon CloudWatch Logs | Centralized streaming for container stdout/stderr log aggregation |

---

## ⚙️ Automated CI/CD Pipeline

The project implements a modern, zero-downtime continuous delivery strategy powered natively by GitHub Actions Workflow.

```text
Developer Push
       │
       ▼
GitHub Actions ──► Docker Multi-stage Build ──► Amazon ECR Push
                                                       │
                                                       ▼
Zero-Downtime Rolling Update ◄── AWS ECS Deployment Update
```

### Pipeline Features

- **Automated Packaging:** Multi-stage Docker builds optimize overall file footprints and compile production-ready layers.
- **ECR Image Versioning:** Builds are dynamically tagged and securely pushed to Amazon ECR.
- **Orchestrated Deployments:** Automates standard rolling deployments to AWS ECS Fargate, ensuring updates happen with zero application downtime.

> 📸 **CI/CD Pipeline — GitHub Actions Execution Log**

<img width="1072" height="496" alt="Screenshot 2026-06-01 234131" src="https://github.com/user-attachments/assets/9f9ae0f4-5b0f-4903-bddd-588b57275624" />


---

## 🔐 Secrets Management

All plain-text environment footprints have been decoupled. Database credentials and runtime configurations are managed inside AWS Secrets Manager and securely injected directly into the ECS containers during runtime via Task Definitions.

### Managed Context Matrix

```text
├── DB_HOST
├── DB_PORT
├── DB_NAME
├── DB_USER
└── DB_PASSWORD
```

> 📸 **AWS Secrets Manager — Credential Store**

<img width="975" height="570" alt="Screenshot 2026-05-25 033945" src="https://github.com/user-attachments/assets/31fed0b2-1b63-4649-ba6a-56f17d26ff20" />


---

## 📂 Project Structure

```text
SkillPulse/
│
├── backend/                  # Golang (Gin Framework) REST API
│   ├── handlers/             # Endpoint Controller Logic
│   ├── models/               # Entities & Data Mappings
│   ├── database/             # Connection Pools & Drivers
│   ├── Dockerfile            # Multi-stage Go Compiler Environment
│   └── main.go               # App Bootstrapper
│
├── frontend/                 # Static Frontend UI Web Server
│   ├── css/                  # Layout & Stylesheets
│   ├── js/                   # App Interactive Client Logic
│   ├── index.html            # Core Framework Window
│   ├── nginx.conf            # Custom Nginx Reverse Proxy Config
│   └── Dockerfile            # Lightweight Production Web Server
│
├── .github/                  # CI/CD Automation
│   └── workflows/
│       └── deploy.yml        # GitHub Actions Workflow Engine
│
└── README.md                 # Project Overview Document
```

---

## 🌐 Load Balancer Routing

The Application Load Balancer (ALB) is configured with two listeners and path-based routing rules to handle HTTPS traffic securely and redirect all plain HTTP requests automatically.

### Listeners

| Listener | Port | Protocol | Action |
|---|---|---|---|
| **HTTPS** | 443 | HTTPS | Forward to target groups via path rules |
| **HTTP Redirect** | 80 | HTTP | Permanent 301 redirect → HTTPS (port 443) |

### Path-Based Routing Rules (HTTPS Listener)

| Path Pattern | Target Group Destination | Service Mapping | Container Port |
|---|---|---|---|
| `/` | Frontend Target Group | Static Content Hosting (Nginx) | Port 80 |
| `/api/*` | Backend Target Group | REST API Framework (Golang) | Port 8080 |

> 📸 **ALB Listener Rules & Target Group Configuration**
>
> [ALB Listener Rules]

<img width="1748" height="872" alt="ALB-listners" src="https://github.com/user-attachments/assets/1748db85-9381-473c-8f9b-b9efd954e5cf" />



> [Target Groups]

<img width="1748" height="826" alt="target-group" src="https://github.com/user-attachments/assets/a287eee8-25b9-4fa3-89fb-b0f4605f9139" />


---

## 🗺️ Step-by-Step Deployment Walkthrough

This section documents the complete infrastructure provisioning lifecycle, broken into three sequential build phases — from raw network foundation to live containerized services.

---

### 🔵 Phase 1 — Network Foundation & Security Hardening

> *Laying the ground rules: isolation, routing, and zero-trust access controls before a single container runs.*

> 📸 **VPC — HLD Architecture**

<img width="2038" height="901" alt="VPC_Network_ECS_FINAL_ARCHITECTURE" src="https://github.com/user-attachments/assets/bfac716d-7b7a-4f85-8974-be06cffeaf1a" />



#### 🌐 VPC & Subnet Architecture

```text
 ┌─────────────────────────────────────────────────────────────────┐
 │                        Custom VPC                               │
 │                                                                 │
 │   ┌─────────────────────────┐  ┌──────────────────────────┐    │
 │   │     Public Subnets      │  │   Private App Subnets    │    │
 │   │  (AZ-1a)   (AZ-1b)     │  │   (AZ-1a)    (AZ-1b)    │    │
 │   │  IGW ───► NAT GW        │  │   ECS Tasks (Fargate)   │    │
 │   └─────────────────────────┘  └──────────────────────────┘    │
 │                                                                 │
 │                   ┌──────────────────────────┐                  │
 │                   │  Private DB Subnets       │                  │
 │                   │  (AZ-1a)    (AZ-1b)      │                  │
 │                   │  RDS MySQL (No IGW/NAT)  │                  │
 │                   └──────────────────────────┘                  │
 └─────────────────────────────────────────────────────────────────┘
```

| Resource | Count | Notes |
|---|---|---|
| **VPC** | 1 | Custom CIDR block; Internet Gateway attached |
| **Public Subnets** | 2 | Hosts ALB, NAT Gateway — spans 2 AZs |
| **Private App Subnets** | 2 | Hosts ECS Fargate tasks — no direct internet exposure |
| **Private DB Subnets** | 2 | Hosts RDS MySQL — fully isolated, no internet path |
| **Internet Gateway** | 1 | Attached to VPC; routes public inbound/outbound traffic |
| **NAT Gateway** | 1 | Deployed in public subnet; enables private outbound-only egress |
| **Route Tables** | 3 | Separate tables per tier with explicit subnet associations |

> 📸 **VPC — Flow Architecture**

<img width="1599" height="871" alt="vpc-creation" src="https://github.com/user-attachments/assets/f3257580-882d-4dd2-81ca-c88f6c5621a2" />


#### 🔒 Security Groups — Tight-Coupled Port Rules

Every Security Group was configured with the principle of **minimum port exposure** and **source-locked ingress** — no wildcard sources unless strictly unavoidable.

```text
┌─────────────────────────────────────────────────────────────────────┐
│                     Security Group Design                            │
│                                                                      │
│  SG-ALB          → Inbound: 80, 443 from 0.0.0.0/0 (internet)      │
│  SG-ECS-Frontend → Inbound: 80   from SG-ALB only                   │
│  SG-ECS-Backend  → Inbound: 8080 from SG-ALB only                   │
│  SG-RDS          → Inbound: 3306 from SG-ECS-Backend only           │
└─────────────────────────────────────────────────────────────────────┘
```

| Security Group | Allowed Port | Allowed Source | Purpose |
|---|---|---|---|
| `SG-ALB` | 80 | `0.0.0.0/0` | HTTP ingress — immediately redirected to HTTPS |
| `SG-ALB` | 443 | `0.0.0.0/0` | HTTPS ingress — TLS termination with ACM cert |
| `SG-ECS-Frontend` | 80 | `SG-ALB` | ALB → Frontend container (internal, post-TLS) |
| `SG-ECS-Backend` | 8080 | `SG-ALB` | ALB → Backend API container (internal, post-TLS) |
| `SG-RDS` | 3306 | `SG-ECS-Backend` | Backend → MySQL database only |

> 📸 **Security Group — Flow Architecture**

<img width="1880" height="751" alt="Security_Group_ECS" src="https://github.com/user-attachments/assets/2766cc0c-9458-4e81-9a37-56da825812c8" />


---

### 🟠 Phase 2 — Container Registry, Load Balancer, Database & Secrets

> *Provisioning the core delivery infrastructure: images, routing, data, and credentials.*

#### 📦 Amazon ECR — Container Image Repositories

Two dedicated repositories were created to store and version containerized application builds:

```text
Amazon ECR
├── skillpulse-frontend     ← Nginx static web server image
└── skillpulse-backend      ← Golang REST API image
```

Both repositories are private, region-scoped, and accessed exclusively by ECS Task Execution Roles via IAM policies.

> 📸 **ECR — Container Image Repositories**
> [ECR Repositories]

<img width="1868" height="592" alt="ECR-Docker-image" src="https://github.com/user-attachments/assets/9b53d580-ac69-4fdc-bb82-b7d0d0862dcb" />


---

#### ⚖️ Application Load Balancer — Path-Based Routing

The ALB uses **IP-mode Target Groups** to route traffic directly to ECS Fargate task IPs (not EC2 instances), enabling seamless serverless integration.

```text
ALB Listener (Port 80)
        │
        ├── Rule 1: Path = "/"        ──►  Target Group: Frontend  (Port 80)
        │
        └── Rule 2: Path = "/api/*"   ──►  Target Group: Backend   (Port 8080)
```

| Target Group | Target Type | Routing Rule | Backend Port | Health Check Path |
|---|---|---|---|---|
| `tg-frontend` | IP | `/` (default) | 80 | `/` |
| `tg-backend` | IP | `/api/*` | 8080 | `/api/health` |

> **Why IP Target Type?** ECS Fargate tasks have no fixed EC2 host. IP-mode target groups register the dynamic ENI IP of each Fargate task directly, enabling proper load balancing without instance management.

---

#### 🔒 Custom Domain & SSL — HTTPS with AWS ACM + CNAME

The application is served over a verified custom domain with end-to-end TLS encryption, provisioned entirely through AWS-native tooling at zero certificate cost.

**Traffic Flow: Browser → DNS → ALB → ECS**

```text
 Browser requests: https://skillpulse.altamash.cloud
        │
        │  DNS Lookup
        ▼
 ┌──────────────────────────────────────────────────────┐
 │  DNS Provider (altamash.cloud)                       │
 │                                                      │
 │  Record Type : CNAME                                 │
 │  Host        : skillpulse                            │
 │  Points To   : <alb-dns-name>.elb.amazonaws.com      │
 └──────────────────────┬───────────────────────────────┘
                        │  Resolves to ALB
                        ▼
 ┌──────────────────────────────────────────────────────┐
 │  Application Load Balancer                           │
 │                                                      │
 │  Listener :443 (HTTPS)                               │
 │  Certificate: AWS ACM → skillpulse.altamash.cloud    │
 │  TLS Termination at ALB edge                         │
 │  HTTP :80 → Permanent 301 Redirect to HTTPS          │
 └──────────────────────┬───────────────────────────────┘
                        │  Decrypted internally
                        ▼
              ECS Fargate Services (Private Subnets)
```

**AWS Certificate Manager (ACM) — Provisioning Steps**

```text
Step 1 → Request public certificate for skillpulse.altamash.cloud in ACM
Step 2 → ACM provides a CNAME validation record (name + value)
Step 3 → Add ACM CNAME validation record to DNS provider
Step 4 → ACM validates domain ownership → Certificate status: ISSUED
Step 5 → Attach issued certificate to ALB HTTPS listener (port 443)
Step 6 → Add HTTP (port 80) listener rule → redirect to HTTPS
```

| Property | Value |
|---|---|
| **Certificate Authority** | AWS Certificate Manager (ACM) |
| **Certificate Type** | Public SSL/TLS |
| **Domain Covered** | `skillpulse.altamash.cloud` |
| **Validation Method** | DNS Validation via CNAME record |
| **Attached To** | ALB HTTPS Listener (Port 443) |
| **TLS Termination Point** | ALB (traffic to ECS is internal) |
| **HTTP → HTTPS Redirect** | Port 80 → 301 Permanent Redirect |
| **Auto-Renewal** | Yes — ACM manages renewal automatically |
| **Cost** | Free (ACM public certificates are no-cost) |

> 📸 **AWS ACM — Issued SSL Certificate**

> [ACM Certificate]

<img width="1736" height="865" alt="Screenshot 2026-05-31 202347" src="https://github.com/user-attachments/assets/f25dbbd5-c9c8-45e1-b874-eda3d612f92d" />

> 📸 **Domain Mapped — skillpulse.altamash.clloud**

<img width="1211" height="97" alt="Screenshot 2026-05-31 202323" src="https://github.com/user-attachments/assets/d5494603-0100-4543-b13c-09d9bda270c7" />



---

#### 🗄️ Amazon RDS MySQL — Isolated Database Provisioning

The RDS instance was provisioned strictly inside the **private DB subnets** with all public access disabled.

```text
 ┌────────────────────────────────────────────────────────────────┐
 │                  RDS Deployment Constraints                    │
 │                                                                │
 │  ✗  No Public IP assigned                                      │
 │  ✗  No Internet Gateway route                                  │
 │  ✗  No SSH / bastion direct access                             │
 │  ✓  Accessible only via SG-ECS-Backend on port 3306           │
 └────────────────────────────────────────────────────────────────┘
```

> 📸 **RDS MySQL Instance — Private Subnet Deployment**
> [RDS Instance]

<img width="1725" height="886" alt="RDS" src="https://github.com/user-attachments/assets/8379b06b-9cc7-46d1-bf8f-a35cc749072d" />


**Database Import Procedure via AWS SSM Session Manager:**

Since the RDS instance has no public access, data was imported through a secure SSM-tunneled session into an intermediary ECS task — avoiding any public exposure. The import sequence followed this pattern:

```bash
# 1. Start SSM session into a temporary ECS task (no SSH required)
aws ecs execute-command --cluster skillpulse-cluster \
  --task <TASK_ID> --container backend \
  --interactive --command "/bin/sh"

# 2. Connect to RDS from within the private network
mysql -h <RDS_ENDPOINT> -u <DB_USER> -p

# 3. Provision the database schema
CREATE DATABASE skillpulse;

# 4. Import dataset
mysql -h <RDS_ENDPOINT> -u <DB_USER> -p skillpulse < data.sql

# 5. Flush privileges and exit
FLUSH PRIVILEGES;
EXIT;
```

> ⚠️ **Security Note:** Database credentials were **never passed as plain-text flags** in production. All credential references were sourced from AWS Secrets Manager at runtime.

---

#### 🔑 AWS Secrets Manager — Runtime Credential Injection

All sensitive database connection parameters are stored as a structured secret in AWS Secrets Manager and injected directly into ECS Task Definitions at container startup — eliminating any hardcoded environment variables.

```text
 Secret: skillpulse/db/credentials
 ┌───────────────────────────────────────────┐
 │  Key              │  Value                │
 │─────────────────────────────────────────  │
 │  DB_HOST          │  <rds-endpoint>       │
 │  DB_PORT          │  3306                 │
 │  DB_NAME          │  skillpulse           │
 │  DB_USER          │  <username>           │
 │  DB_PASSWORD      │  <password>           │
 └───────────────────────────────────────────┘
        │
        ▼
 ECS Task Definition → secretsFrom: arn:aws:secretsmanager:...
        │
        ▼
 Container Environment (injected at runtime, never stored in image)
```

---

### 🟢 Phase 3 — ECS Cluster, Task Definitions & Service Deployment

> *Bringing the application to life: orchestrating containers on serverless Fargate infrastructure.*

#### 🔐 IAM Roles — Task Execution Role & Task Role

ECS Fargate requires **two distinct IAM roles** per Task Definition. These are commonly confused but serve completely different purposes — one is for the AWS control plane, the other is for the running application itself.

```text
 ┌─────────────────────────────────────────────────────────────────────┐
 │                    ECS IAM Role Architecture                        │
 │                                                                     │
 │   Task Execution Role (Control Plane)                               │
 │   └── Used BY: ECS Agent & Fargate infrastructure                  │
 │       ├── Pull container image from Amazon ECR                      │
 │       ├── Fetch secrets from AWS Secrets Manager                    │
 │       └── Push logs to Amazon CloudWatch                            │
 │                                                                     │
 │   Task Role (Application Plane)                                     │
 │   └── Used BY: Code running INSIDE the container                   │
 │       ├── SSM Session Manager — ECS Exec (interactive shell)        │
 │       └── Any AWS SDK calls made by the application at runtime      │
 └─────────────────────────────────────────────────────────────────────┘
```

---

##### 🛠️ Task Execution Role — `skillpulse-execution-role`

This role is assumed by the **ECS control plane** before the container even starts. Without it, Fargate cannot pull your image from ECR or inject secrets into the container environment.

| Permission | AWS Managed / Inline Policy | Purpose |
|---|---|---|
| `ecr:GetAuthorizationToken` | `AmazonECSTaskExecutionRolePolicy` | Authenticate to ECR registry |
| `ecr:BatchGetImage` | `AmazonECSTaskExecutionRolePolicy` | Pull container image layers |
| `ecr:GetDownloadUrlForLayer` | `AmazonECSTaskExecutionRolePolicy` | Download image layer blobs |
| `secretsmanager:GetSecretValue` | Inline policy | Fetch DB credentials from Secrets Manager at startup |
| `logs:CreateLogStream` | `AmazonECSTaskExecutionRolePolicy` | Create CloudWatch log stream |
| `logs:PutLogEvents` | `AmazonECSTaskExecutionRolePolicy` | Ship container logs to CloudWatch |

**Trust Policy — who can assume this role:**

```json
{
  "Effect": "Allow",
  "Principal": {
    "Service": "ecs-tasks.amazonaws.com"
  },
  "Action": "sts:AssumeRole"
}
```

---

##### 🖥️ Task Role — `skillpulse-task-role`

This role is assumed by the **application running inside the container**. It is required specifically to enable **ECS Exec** — the SSM-based interactive shell that lets you `exec` directly into a live Fargate task without SSH or a bastion host.

| Permission | Policy | Purpose |
|---|---|---|
| `ssmmessages:CreateControlChannel` | Inline policy | Open SSM control channel for ECS Exec |
| `ssmmessages:CreateDataChannel` | Inline policy | Open SSM data channel for shell I/O |
| `ssmmessages:OpenControlChannel` | Inline policy | Maintain SSM control connection |
| `ssmmessages:OpenDataChannel` | Inline policy | Maintain SSM data stream for interactive shell |

**Inline Policy Document:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    }
  ]
}
```

> ⚠️ **Important:** `EnableExecuteCommand: true` must also be set on the ECS **Service** (not just the Task Definition) for ECS Exec to work. Both conditions — the Task Role SSM permissions AND the service flag — must be present simultaneously.

---

##### 🔑 ECS Exec — Interactive Shell Into a Live Fargate Task

With the Task Role and service flag configured, you can open a real-time interactive shell into any running Fargate container — no SSH, no bastion, no public IP required.

```text
 Developer Machine
       │
       │  aws ecs execute-command (CLI / IAM authenticated)
       ▼
 AWS SSM Service  ←──────────────────────────────────────┐
       │                                                  │
       │  SSM Control + Data Channel                      │
       ▼                                                  │
 ECS Fargate Task (Private Subnet)                        │
       │  ssm-agent sidecar process                       │
       └──────────────────────────────────────────────────┘
             Interactive /bin/sh shell session
             (No internet, no SSH port, no bastion)
```

**ECS Exec Command — Connect to a Live Container:**

```bash
# List running tasks to get the Task ID
aws ecs list-tasks \
  --cluster skillpulse-cluster \
  --service-name skillpulse-backend-service

# Open an interactive shell into the backend container
aws ecs execute-command \
  --cluster skillpulse-cluster \
  --task <TASK_ID> \
  --container backend \
  --interactive \
  --command "/bin/sh"

# Once inside — example debug commands
env | grep DB_          # verify secrets were injected correctly
curl localhost:8080/api/health   # test internal API response
mysql -h $DB_HOST -u $DB_USER -p  # connect to RDS from within the task
```

> 📸 **ECS Exec — SSM Interactive Shell Session**


---

##### 📊 Role Assignment Per Task Definition

| Role Type | Role Name | Assigned To | Key Permissions |
|---|---|---|---|
| **Task Execution Role** | `skillpulse-execution-role` | Both task definitions | ECR pull, Secrets Manager, CloudWatch logs |
| **Task Role** | `skillpulse-task-role` | Both task definitions | SSM `ssmmessages.*` for ECS Exec |

---

#### 🧱 ECS Cluster Overview

A single ECS Cluster named `skillpulse-cluster` hosts both application services, leveraging **AWS Fargate** as the serverless compute engine — no EC2 instances to provision, patch, or manage.

```text
 ECS Cluster: skillpulse-cluster
 ├── Service 1: skillpulse-frontend-service  [EnableExecuteCommand: true]
 │     └── Task Definition: skillpulse-frontend-td
 │           ├── Container: nginx (frontend image from ECR)
 │           ├── Port Mapping: 80
 │           ├── Task Execution Role: skillpulse-execution-role
 │           ├── Task Role: skillpulse-task-role (SSM / ECS Exec)
 │           ├── Log Driver: awslogs → CloudWatch
 │           └── Secrets: (none — static content)
 │
 └── Service 2: skillpulse-backend-service   [EnableExecuteCommand: true]
       └── Task Definition: skillpulse-backend-td
             ├── Container: go-api (backend image from ECR)
             ├── Port Mapping: 8080
             ├── Task Execution Role: skillpulse-execution-role
             ├── Task Role: skillpulse-task-role (SSM / ECS Exec)
             ├── Log Driver: awslogs → CloudWatch
             └── Secrets: DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
                          (injected from AWS Secrets Manager via Execution Role)
```

> 📸 **ECS Cluster — Active Cluster Overview**

> [ECS Cluster]

<img width="1739" height="850" alt="ECS-service-status" src="https://github.com/user-attachments/assets/07468b89-238c-4140-9bed-35caeb26d4dd" />


#### 📋 ECS Component Configuration Summary

**Frontend Service**

| Property | Value |
|---|---|
| Launch Type | AWS Fargate |
| Task Definition | `skillpulse-frontend-td` |
| Container Image | `ECR → skillpulse-frontend:latest` |
| Container Port | `80` |
| Target Group | `tg-frontend` |
| Subnet Placement | Private App Subnets |
| Security Group | `SG-ECS-Frontend` |
| **Task Execution Role** | `skillpulse-execution-role` (ECR pull, CloudWatch logs) |
| **Task Role** | `skillpulse-task-role` (SSM ECS Exec) |
| ECS Exec Enabled | `true` |
| CloudWatch Log Group | `/ecs/skillpulse-frontend` |

**Backend Service**

| Property | Value |
|---|---|
| Launch Type | AWS Fargate |
| Task Definition | `skillpulse-backend-td` |
| Container Image | `ECR → skillpulse-backend:latest` |
| Container Port | `8080` |
| Target Group | `tg-backend` |
| Subnet Placement | Private App Subnets |
| Security Group | `SG-ECS-Backend` |
| **Task Execution Role** | `skillpulse-execution-role` (ECR pull, Secrets Manager, CloudWatch logs) |
| **Task Role** | `skillpulse-task-role` (SSM ECS Exec) |
| ECS Exec Enabled | `true` |
| Secret Injection | AWS Secrets Manager → `skillpulse/db/credentials` |
| CloudWatch Log Group | `/ecs/skillpulse-backend` |

> 📸 **ECS Services & Running Tasks**
>
> [ECS Services]
<img width="1739" height="850" alt="ECS-service-status" src="https://github.com/user-attachments/assets/b3647427-ea9a-4710-b1d8-84e20a0ae755" />

> [ECS Tasks]
 <img width="1739" height="803" alt="ECS-task-status" src="https://github.com/user-attachments/assets/aef204b2-0143-4c19-ad42-60ac5d7cbb1e" />


#### 🔄 End-to-End Deployment Flow

```text
Phase 1                    Phase 2                          Phase 3
──────────                 ──────────                       ──────────
VPC + Subnets         →    ECR Repositories            →    IAM Execution Role
IGW + NAT GW          →    ALB + Target Groups         →    IAM Task Role (SSM)
Route Tables          →    ACM SSL Certificate         →    ECS Cluster
Security Groups       →    CNAME → ALB DNS             →    Task Definitions
                      →    RDS MySQL (Private)         →    Frontend Service
                      →    Secrets Manager             →    Backend Service
                                                             │
                                                             ▼
                                                   ✅ https://skillpulse.altamash.cloud
```

---

## 📊 Centralized Observability — CloudWatch Logs

All container stdout/stderr streams are forwarded to Amazon CloudWatch Logs in real time via the `awslogs` driver configured in each Task Definition. This provides a unified, searchable audit trail across both services without needing SSH access to any host.

```text
/ecs/skillpulse-frontend   ← Nginx access logs, error logs
/ecs/skillpulse-backend    ← Go API request logs, error traces, DB connection events
```

> 📸 **CloudWatch — Centralized Container Log Streams**

> [CloudWatch Logs: Frontend]

<img width="1756" height="830" alt="log-frontend-sucess" src="https://github.com/user-attachments/assets/f2494cb4-c6c6-4bd3-bf5d-28b985526ab7" />


> [CloudWatch Logs: Backend]
<img width="1654" height="902" alt="log-backend-success" src="https://github.com/user-attachments/assets/31bd1ad7-ce81-48b5-b465-06e9b0ff7193" />
---

> 📸 **Final Result — Secure HTTPS Connection**

<img width="1869" height="992" alt="DomainMapped" src="https://github.com/user-attachments/assets/341d4557-7f4a-4b00-9237-f7cf024fcb05" />


## ⚡ Challenges Faced & Engineering Solutions

During the deployment lifecycle, several real-world enterprise obstacles were encountered, troubleshot, and resolved:

**ECS and ECR Connectivity Interferences**
- *Problem:* ECS Fargate tasks stayed suspended in a `PENDING` phase, failing to pull container images from ECR.
- *Resolution:* Root-cause analysis isolated missing route pathways within the private subnet architecture. Route table entries were updated to point targeting paths out safely through the NAT Gateway.

**Target Group Health Check Expirations**
- *Problem:* ECS services iteratively failed ALB health check cycles, triggering unnecessary task recycles.
- *Resolution:* Audited inconsistencies between target group endpoints and internal server listeners. Rewrote paths and updated targets to align accurately with operational status requirements.

**Database Timing Failures**
- *Problem:* API layers initially dropped connectivity to MySQL during early cluster launch synchronization windows.
- *Resolution:* Implemented standard reconnection retry driver logic within the backend codebase and refined underlying ingress security groups.

**Interactive Fargate Debugging Mechanics**
- *Problem:* Inspecting internal application drift directly within serverless Fargate tasks is complex due to a lack of host server access.
- *Resolution:* Active states were resolved by introducing and configuring ECS Exec. Necessary IAM execution statements and SSM integrations were embedded to safely initialize interactive shell container inspections.

---

## 📚 Key Learnings & Implemented Best Practices

This architecture demonstrates a production-ready baseline incorporating crucial industry DevOps practices:

- **High Availability Topology:** Deployed across multiple Availability Zones (Multi-AZ) ensuring infrastructural redundancy.
- **Zero Trust Data Segmentation:** Application layers and data tiers are segregated completely into private subnet scopes.
- **Zero Hardcoded Secrets:** Configuration keys are fully abstracted away using AWS Secrets Manager.
- **Centralized Observability:** Fully structured application tracing and performance auditing using Amazon CloudWatch.
- **Principal of Least Privilege:** Highly customized IAM Execution Policies tailored to isolate permissions per execution resource block.

---

## 🚀 Execution & Command Reference

### Local Container Verification

```bash
# Compile and containerize the Frontend Component locally
docker build -t skillpulse-frontend ./frontend

# Compile and containerize the Backend Component locally
docker build -t skillpulse-backend ./backend
```

### Manual Service Deployment Update

```bash
# Push container images up to remote cloud registries
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/skillpulse-backend:latest

# Trigger a zero-downtime rolling task update across an ECS Cluster
aws ecs update-service --cluster skillpulse-cluster --service skillpulse-backend-service --force-new-deployment
```

---

## 👨‍💻 Author

**Altamash**  
*Cloud Infrastructure Professional & DevOps Engineer*

---

## ⭐ Show Your Support

If this project or repository was helpful to your AWS cloud engineering or DevOps journey, please consider giving this repository a **star**!
