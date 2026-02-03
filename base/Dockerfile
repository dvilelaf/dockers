# Base image with SSH and david user
FROM python:3.13.2-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH and basic dependencies
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    git \
    ca-certificates \
    gnupg \
    sudo \
    locales \
    nano \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/es_ES.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

ENV LANG=es_ES.UTF-8
ENV LC_ALL=es_ES.UTF-8

# Install uv globally
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/ \
    && mv /root/.local/bin/uvx /usr/local/bin/

# Create david user with home, bash and sudo (unlocked for SSH)
RUN useradd -m -s /bin/bash david \
    && usermod -aG sudo david \
    && passwd -d david

# Configure SSH: public key authentication only
RUN mkdir -p /var/run/sshd \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Prepare directory and authorized SSH key
RUN mkdir -p /home/david/.ssh \
    && echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGatOYBvLWOmG9cYWipWjN9TBK/eeI5DX5t6tXPtw4uh david@main" > /home/david/.ssh/authorized_keys \
    && chmod 700 /home/david/.ssh \
    && chmod 600 /home/david/.ssh/authorized_keys \
    && chown -R david:david /home/david/.ssh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
