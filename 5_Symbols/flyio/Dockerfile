FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV KILO_CONFIG_DIR=/root/.config/kilo

# Install core dependencies, Node.js 20, Kilo CLI, and ttyd (real browser terminal)
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
    && TTYD_VERSION=1.7.7 \
    && curl -fsSL -o /usr/local/bin/ttyd \
       "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" \
    && chmod +x /usr/local/bin/ttyd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SSH runtime directories
RUN mkdir -p /var/run/sshd /root/.ssh \
    && chmod 700 /root/.ssh

# Persistent workspace (mounted via Fly Volume)
RUN mkdir -p /root/projects /root/.config/kilo

EXPOSE 2222 7681

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
