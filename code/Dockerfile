# Dockerfile with Claude Code and Takopi
FROM dvilela/base

# Install Node.js (required by Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code for david user
RUN su - david -c "curl -fsSL https://claude.ai/install.sh | bash"
ENV PATH="/home/david/.claude/local/bin:$PATH"

# Install takopi for david user
RUN su - david -c "uv tool install -U takopi"

# Working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
