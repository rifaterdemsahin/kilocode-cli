FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV KILO_CONFIG_DIR=/root/.config/kilo

# Install core dependencies, Node.js 20, and Kilo CLI
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    openssh-server \
    nano \
    vim \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && NODE_MAJOR=20 \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
       | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g @kilocode/cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SSH runtime directories
RUN mkdir -p /var/run/sshd /root/.ssh \
    && chmod 700 /root/.ssh

# Persistent workspace (mounted via Fly Volume)
RUN mkdir -p /root/projects /root/.config/kilo

EXPOSE 2222

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
