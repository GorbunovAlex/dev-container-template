FROM golang:1.24 AS base

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash fd-find curl cargo ripgrep ffmpeg libc6
# Install Node.js
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION latest
RUN mkdir -p $NVM_DIR \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install node \
  && nvm alias default node \
  && nvm use default

# Add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install Neovim 0.11.0
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz && \
  tar -xzf nvim-linux-x86_64.tar.gz && \
  mv nvim-linux-x86_64 /usr/local/nvim && \
  ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim && \
  rm nvim-linux-x86_64.tar.gz && \
  git clone https://github.com/GorbunovAlex/nvim_config.git ~/.config/nvim

EXPOSE 8080
CMD ["tail", "-f", "/dev/null"]
