ARG VARIANT="noble"
FROM buildpack-deps:${VARIANT}-curl

RUN if [ "$VARIANT" = "noble" ] || [ "$VARIANT" = "questing" ]; then \
        if id "ubuntu" &>/dev/null; then \
            echo "Deleting user 'ubuntu'  for $VARIANT" && userdel -f -r ubuntu || echo "Failed to delete ubuntu user for $VARIANT"; \  
        else \
            echo "User 'ubuntu' does not exist for $VARIANT"; \ 
        fi; \
    fi

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        stow \
        zoxide \
        ripgrep \
        bat \
        fd-find \
        fzf \
        eza \
        git \
    && git clone https://github.com/zsh-users/zsh-autosuggestions /usr/local/share/zsh-autosuggestions \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
