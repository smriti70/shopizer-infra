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
│  │  │  shopizer-backend (2 pods)                      │   │     │
│  │  │  ┌──────────┐  ┌──────────┐                     │   │     │
│  │  │  │ pod 1    │  │ pod 2    │  NodePort: 30090    │   │     │
│  │  │  │ :8080    │  │ :8080    │                     │   │     │
│  │  │  └──────────┘  └──────────┘                     │   │     │
│  │  │                                                 │   │     │
│  │  │  shopizer-admin (2 pods)                        │   │     │
│  │  │  ┌──────────┐  ┌──────────┐                     │   │     │
│  │  │  │ pod 1    │  │ pod 2    │  NodePort: 30091    │   │     │
│  │  │  │ :80      │  │ :80      │                     │   │     │
│  │  │  └──────────┘  └──────────┘                     │   │     │
│  │  │                                                 │   │     │
│  │  │  shopizer-shop (2 pods)                         │   │     │
│  │  │  ┌──────────┐  ┌──────────┐                     │   │     │
│  │  │  │ pod 1    │  │ pod 2    │  NodePort: 30001    │   │     │
│  │  │  │ :80      │  │ :80      │                     │   │     │
│  │  │  └──────────┘  └──────────┘                     │   │     │
│  │  └─────────────────────────────────────────────────┘   │     │
│  └────────────────────────────────────────────────────────┘     │
│           │                  │                  │               │
│        :30090             :30091             :30001             │
└─────────────────────────────────────────────────────────────────┘
```

## Port Mapping

| Service  | Container Port | NodePort | URL                    |
|----------|---------------|----------|------------------------|
| Backend  | 8080          | 30090    | http://localhost:30090 |
| Admin    | 80            | 30091    | http://localhost:30091 |
| Shop     | 80            | 30001    | http://localhost:30001 |

## Docker Images (Docker Hub)

| Service  | Image                            |
|----------|----------------------------------|
| Backend  | smriti70/shopizer-backend:latest |
| Admin    | smriti70/shopizer-admin:latest   |
| Shop     | smriti70/shopizer-shop:latest    |

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
(2 pods)  (2 pods)  (2 pods)
```

## Rolling Updates

With 2 replicas per service, Kubernetes performs zero-downtime rolling updates:
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
├── main.tf          # provider, module calls for all 3 services
├── variables.tf     # image tags, host config
├── outputs.tf       # service URLs
└── modules/
    └── k8s-service/ # reusable Deployment + NodePort Service
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
