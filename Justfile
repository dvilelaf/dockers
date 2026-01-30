# Justfile to build and publish Docker containers

set dotenv-load

# Variables
base_image := "dvilela/base"
code_image := "dvilela/code"

# Build base image
build-base:
    docker build -t {{base_image}} base/

# Build code image
build-code:
    docker build -t {{code_image}} code/

# Build both images (base first)
build: build-base build-code

# Push base image
push-base:
    docker push {{base_image}}

# Push code image
push-code:
    docker push {{code_image}}

# Push both images
push: push-base push-code

# Build and push base
release-base: build-base push-base

# Build and push code
release-code: build-code push-code

# Build and push everything
release: build push

# Clean local images
clean:
    docker rmi {{base_image}} {{code_image}} || true

# Portainer Proxmox
portainer_url_proxmox := env("PORTAINER_URL_PROXMOX", "")
portainer_token_proxmox := env("PORTAINER_API_TOKEN_PROXMOX", "")
portainer_endpoint_proxmox := env("PORTAINER_ENDPOINT_ID_PROXMOX", "1")

# Portainer Robaleira
portainer_url_robaleira := env("PORTAINER_URL_ROBALEIRA", "")
portainer_token_robaleira := env("PORTAINER_API_TOKEN_ROBALEIRA", "")
portainer_endpoint_robaleira := env("PORTAINER_ENDPOINT_ID_ROBALEIRA", "1")

code_stack_id := env("CODE_STACK_ID", "")

# Deploy code stack to Portainer Proxmox
deploy-code:
    @if [ -z "{{portainer_url_proxmox}}" ] || [ -z "{{portainer_token_proxmox}}" ] || [ -z "{{code_stack_id}}" ]; then \
        echo "Error: Set PORTAINER_URL_PROXMOX, PORTAINER_API_TOKEN_PROXMOX, and CODE_STACK_ID in .env"; \
        exit 1; \
    fi
    @echo "Deploying code stack to Portainer..."
    @response=$(curl -s -X PUT "{{portainer_url_proxmox}}/api/stacks/{{code_stack_id}}?endpointId={{portainer_endpoint_proxmox}}" \
        -H "X-API-Key: {{portainer_token_proxmox}}" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg content "$(cat code/docker-compose.yml)" '{stackFileContent: $content, pullImage: true, prune: false}')"); \
    if echo "$response" | jq -e '.Id' > /dev/null 2>&1; then \
        echo "OK: Stack deployed successfully"; \
    else \
        echo "FAILED: $(echo "$response" | jq -r '.message // .details // "Unknown error"')"; \
        exit 1; \
    fi

# Deploy a stack to any Portainer (generic helper)
_deploy-stack url token endpoint stack_id compose_file:
    @echo "Deploying to Portainer..."
    @response=$(curl -s -X PUT "{{url}}/api/stacks/{{stack_id}}?endpointId={{endpoint}}" \
        -H "X-API-Key: {{token}}" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg content "$(cat {{compose_file}})" '{stackFileContent: $content, pullImage: true, prune: false}')"); \
    if echo "$response" | jq -e '.Id' > /dev/null 2>&1; then \
        echo "OK: Stack deployed successfully"; \
    else \
        echo "FAILED: $(echo "$response" | jq -r '.message // .details // "Unknown error"')"; \
        exit 1; \
    fi

# Deploy any stack to Robaleira
deploy-robaleira stack_id compose_file:
    @if [ -z "{{portainer_url_robaleira}}" ] || [ -z "{{portainer_token_robaleira}}" ]; then \
        echo "Error: Set PORTAINER_URL_ROBALEIRA and PORTAINER_API_TOKEN_ROBALEIRA in .env"; \
        exit 1; \
    fi
    @just _deploy-stack "{{portainer_url_robaleira}}" "{{portainer_token_robaleira}}" "{{portainer_endpoint_robaleira}}" "{{stack_id}}" "{{compose_file}}"

# Full release: build, push, and deploy code
release-deploy: release deploy-code
