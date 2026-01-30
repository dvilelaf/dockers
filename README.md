# dockers

A collection of Docker images for development environments.

## Images

### base (`dvilela/base`)

Base image with SSH access and user `david`. Features:

- Python 3.13 (slim)
- SSH server with public key authentication
- User `david` with sudo access
- uv package manager (globally available)
- Spanish locale (es_ES.UTF-8)

**Environment variables:**
- `DAVID_PASSWORD`: Set password for user david. If not set, uses temporary password `david` and forces change on first sudo.

### code (`dvilela/code`)

Development environment based on `dvilela/base`. Includes:

- Node.js 22
- Claude Code CLI
- takopi

## Usage

Build and push all images:

```bash
just release
```

Individual commands:

```bash
just build-base    # Build base image
just build-code    # Build code image
just push-base     # Push base image
just push-code     # Push code image
just release-base  # Build and push base
just release-code  # Build and push code
just clean         # Remove local images
```

## Portainer deployment

Create a `.env` file with your Portainer credentials:

```bash
# Proxmox Portainer
PORTAINER_URL_PROXMOX="https://portainer-proxmox.example.com"
PORTAINER_API_TOKEN_PROXMOX="your-api-token"
PORTAINER_ENDPOINT_ID_PROXMOX="3"
CODE_STACK_ID="10"

# Robaleira Portainer
PORTAINER_URL_ROBALEIRA="https://portainer-robaleira.example.com"
PORTAINER_API_TOKEN_ROBALEIRA="your-api-token"
PORTAINER_ENDPOINT_ID_ROBALEIRA="1"
```

Then deploy:

```bash
just deploy-code                              # Deploy code to Proxmox
just release-deploy                           # Build, push, and deploy code
just deploy-robaleira <stack_id> <compose>    # Deploy any stack to Robaleira
```

## docker-compose example

See `code/docker-compose.yml` for a complete example.
