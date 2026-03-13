# Shopizer Infrastructure Diagram

## Stack Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        macOS Host                           │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                  Colima VM (Docker)                  │   │
│  │                                                      │   │
│  │         ┌─────────── shopizer-network ────────────┐  │   │
│  │         │                                         │  │   │
│  │  ┌──────┴──────┐  ┌─────────────┐  ┌──────────┐  │  │   │
│  │  │   backend   │  │    admin    │  │   shop   │  │  │   │
│  │  │─────────────│  │─────────────│  │──────────│  │  │   │
│  │  │ Spring Boot │  │  Angular    │  │  React   │  │  │   │
│  │  │  :8080      │  │  nginx :80  │  │ nginx:80 │  │  │   │
│  │  └──────┬──────┘  └──────┬──────┘  └────┬─────┘  │  │   │
│  │         └────────────────┴───────────────┘        │  │   │
│  └───────────────────────────────────────────────────┘  │   │
│           │                  │                  │        │   │
│        :8090              :8091              :3001       │   │
└─────────────────────────────────────────────────────────────┘
```

## Port Mapping

| Service  | Container Port | Host Port | URL                   |
|----------|---------------|-----------|-----------------------|
| Backend  | 8080          | 8090      | http://localhost:8090 |
| Admin    | 80            | 8091      | http://localhost:8091 |
| Shop     | 80            | 3001      | http://localhost:3001 |

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
    terraform apply (Colima)
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
 backend    admin     shop
```

## Terraform Module Structure

```
shopizer-infra/
├── main.tf          # provider, network, module calls
├── variables.tf     # image tags, host config
├── outputs.tf       # service URLs
└── modules/
    └── container/   # reusable docker_image + docker_container
```
