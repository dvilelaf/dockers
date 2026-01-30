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

# Override entrypoint to start takopi
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Working directory
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
