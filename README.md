# GamU Infrastructure

Infrastructure provisioning and deployment for the GamU platform on DigitalOcean.

## Tech Stack

| Layer | Technology |
|-------|------------|
| IaaS | DigitalOcean Droplet (Ubuntu 22.04) |
| Provisioning | OpenTofu |
| Containerization | Docker Compose |
| Reverse Proxy | Nginx 1.31.1 (SSL termination) |
| SSL | Let's Encrypt via Certbot (webroot) |
| CI/CD | GitHub Actions → GHCR |
| Frontend | TanStack Start (React) + Nitro |
| Backend | Effect.ts + @effect/platform (unstable) |
| ML | Python (separate VM) |

## Repository Structure

```
infrastructure/
├── main.tf                  # OpenTofu droplet + firewall
├── variables.tf             # OpenTofu variables
├── outputs.tf               # Droplet IP outputs
├── cloud-init.yaml          # Docker installation on droplet
├── docker-compose.yml       # Service definitions
├── conf.d/
│   └ default.conf          # Nginx HTTP config (certbot + HTTPS redirect)
├── nginx-ssl.conf           # Nginx HTTPS config (subdomain routing)
├── setup-ssl.sh             # Certbot SSL setup (multi-subdomain)
├── backend.env.example      # Backend env reference
├── frontend.env.example     # Frontend env reference
└── ci-templates/            # GitHub Actions deploy templates
```