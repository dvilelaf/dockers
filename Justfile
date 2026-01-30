# Justfile to build and publish Docker containers

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
