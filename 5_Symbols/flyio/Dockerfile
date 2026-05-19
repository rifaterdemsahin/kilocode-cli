FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV KILO_CONFIG_DIR=/root/.config/kilo
ENV TERM=xterm-256color
ENV NODE_NO_WARNINGS=1
ENV CI=true

# Install core dependencies, Node.js 20, Kilo CLI, ttyd, and diagnostic tools
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    openssh-server \
    nano \
    vim \
    iputils-ping \
    dnsutils \
    netcat-openbsd \
    tmux \
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

# Cache the kilo binary path to speed up wrapper startup
RUN KILO_REAL=$(find /usr/lib/node_modules -name kilo -path '*/@kilocode/cli-linux*/bin/*' -print -quit 2>/dev/null) \
    && if [ -n "$KILO_REAL" ]; then \
         ln -sf "$KILO_REAL" /usr/lib/node_modules/@kilocode/cli/.kilo; \
         echo "Cached kilo binary: $KILO_REAL"; \
       else \
         echo "⚠ No cached kilo binary found — wrapper will search on each run"; \
       fi

# Verify kilo binary works
RUN which kilo && kilo --version

# Colorful bash prompt + tmux alias for TUI apps
RUN echo 'export PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "' >> /root/.bashrc \
    && echo 'export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32"' >> /root/.bashrc \
    && echo 'alias ls="ls --color=auto"' >> /root/.bashrc \
    && echo 'alias ll="ls -la --color=auto"' >> /root/.bashrc \
    && echo 'alias grep="grep --color=auto"' >> /root/.bashrc \
    && echo 'alias kilo="tmux new-session -A -s kilo -n kilo kilo"' >> /root/.bashrc

# SSH runtime directories
RUN mkdir -p /var/run/sshd /root/.ssh \
    && chmod 700 /root/.ssh

# Persistent workspace (mounted via Fly Volume)
RUN mkdir -p /root/projects /root/.config/kilo

EXPOSE 2222 7681

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
