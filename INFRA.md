# Shopizer Infrastructure Diagram

## Stack Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                          macOS Host                             │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐     │
│  │              Colima VM (Kubernetes / k3s)              │     │
│  │                                                        │     │
│  │  ┌─────────────────────────────────────────────────┐   │     │
│  │  │               default namespace                 │   │     │
│  │  │                                                 │   │     │
│  │  │  shopizer-backend (1 pod)                       │   │     │
│  │  │  ┌──────────────────────┐                       │   │     │
│  │  │  │ pod 1  :8080         │  backend.shopizer.local│  │     │
│  │  │  └──────────────────────┘                       │   │     │
│  │  │                                                 │   │     │
│  │  │  shopizer-admin (2 pods)                        │   │     │
│  │  │  ┌──────────┐  ┌──────────┐                     │   │     │
│  │  │  │ pod 1    │  │ pod 2    │  admin.shopizer.local│  │     │
│  │  │  │ :80      │  │ :80      │                     │   │     │
│  │  │  └──────────┘  └──────────┘                     │   │     │
│  │  │                                                 │   │     │
│  │  │  shopizer-shop (2 pods)                         │   │     │
│  │  │  ┌──────────┐  ┌──────────┐                     │   │     │
│  │  │  │ pod 1    │  │ pod 2    │  shopizer.local      │  │     │
│  │  │  │ :80      │  │ :80      │                     │   │     │
│  │  │  └──────────┘  └──────────┘                     │   │     │
│  │  │                                                 │   │     │
│  │  │  nginx ingress controller                       │   │     │
│  │  └─────────────────────────────────────────────────┘   │     │
│  └────────────────────────────────────────────────────────┘     │
│                          :80                                    │
└─────────────────────────────────────────────────────────────────┘
```

## URLs

| Service  | URL                            |
|----------|--------------------------------|
| Shop     | http://shopizer.local          |
| Admin    | http://admin.shopizer.local    |
| Backend  | http://backend.shopizer.local  |

## /etc/hosts (required)

```
127.0.0.1 shopizer.local
127.0.0.1 admin.shopizer.local
127.0.0.1 backend.shopizer.local
```

## Docker Images (Docker Hub)

| Service  | Image                            |
|----------|----------------------------------|
| Backend  | smriti70/shopizer-backend:latest |
| Admin    | smriti70/shopizer-admin:latest   |
| Shop     | smriti70/shopizer-shop:latest    |

## Replicas

| Service  | Replicas | Reason                                      |
|----------|----------|---------------------------------------------|
| Backend  | 1        | H2 embedded DB cannot be shared across pods |
| Admin    | 2        | Stateless, supports rolling updates         |
| Shop     | 2        | Stateless, supports rolling updates         |

## CI/CD Pipeline

```
GitHub Push
    │
    ▼
GitHub Actions
    ├── Run Tests
    ├── Build Artifact
    ├── Build Docker Image
    └── Push to Docker Hub
              │
              ▼
         Docker Hub
              │
              ▼
    terraform apply (Colima k3s)
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
 backend    admin     shop
 (1 pod)  (2 pods)  (2 pods)
```

## Rolling Updates

With 2 replicas (admin and shop), Kubernetes performs zero-downtime rolling updates:
- New pod starts and passes readiness probe
- Old pod is terminated only after new pod is healthy
- Traffic is never interrupted

## What is k3s

k3s is a lightweight Kubernetes distribution used by Colima. It is fully
compatible with standard Kubernetes APIs and kubectl, but runs in a single
binary with lower memory usage — making it ideal for local development.

## Usage

### Start
```bash
colima start --kubernetes --cpu 4 --memory 8
terraform init   # first time only
terraform apply -auto-approve
```
> Note: Backend may take a couple of minutes to fully start.

### Stop & Destroy
```bash
terraform destroy -auto-approve
colima stop
```

## Terraform Module Structure

```
shopizer-infra/
├── main.tf          # provider, ingress, module calls for all 3 services
├── variables.tf     # image tags
├── outputs.tf       # service URLs
└── modules/
    └── k8s-service/ # reusable Deployment + ClusterIP Service
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
