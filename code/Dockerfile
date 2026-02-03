# Dockerfile with Claude Code and Takopi
FROM dvilela/base

# Install build tools (gcc, make) and dev libraries for Python packages
# Required for: safe-pysha3, ed25519-blake2b, and other native extensions
# Also install gitleaks for security scanning
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/v8.21.2/gitleaks_8.21.2_linux_x64.tar.gz | tar -xz -C /usr/local/bin gitleaks

# Install Node.js (required by Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code for david user
RUN su - david -c "curl -fsSL https://claude.ai/install.sh | bash"
ENV PATH="/home/david/.claude/local/bin:$PATH"

# Install takopi for david user
RUN su - david -c "uv tool install -U takopi"

# Override entrypoint to start takopi
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Working directory
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
