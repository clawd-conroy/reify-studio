# Elixir/Phoenix development container
# Official elixir image supports ARM64 (Apple Silicon)
# Using full image (not slim) for devcontainer convenience
FROM elixir:1.19-otp-27

# Install additional dependencies not in base image
RUN apt-get update -y && apt-get install -y \
    cmake \
    inotify-tools \
    postgresql-client \
    sudo \
    ca-certificates \
    gnupg \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update -y \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (for Codespaces port management)
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list \
    && apt-get update -y \
    && apt-get install -y gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
ARG USERNAME=elixir
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Pre-create volume mount points with correct ownership
# This ensures named volumes inherit these permissions
RUN mkdir -p /workspace/deps /workspace/_build /workspace/assets/node_modules \
    && chown -R $USER_UID:$USER_GID /workspace

# Install hex and rebar as root first (global)
RUN mix local.hex --force && \
    mix local.rebar --force

# Switch to non-root user
USER $USERNAME

# Install hex and rebar for user
RUN mix local.hex --force && \
    mix local.rebar --force

# Install oh-my-zsh (pinned to specific commit for supply chain security)
# Commit: b52dd1a425e9ed9f844ba46cd27ff94a3b4949dc (Nov 2025)
# To update: check https://github.com/ohmyzsh/ohmyzsh/commits/master/tools/install.sh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/b52dd1a425e9ed9f844ba46cd27ff94a3b4949dc/tools/install.sh)" "" --unattended \
    && echo '\n# Aliases\nalias ll="ls -la"\nalias la="ls -A"\nalias l="ls -CF"\n' >> /home/elixir/.zshrc

# Set working directory
WORKDIR /workspace

# Default command
CMD ["zsh"]
