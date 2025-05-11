FROM golang:1.24-bullseye AS base

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash fd-find curl cargo ripgrep ffmpeg

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

# Install Neovim from source
RUN mkdir -p /root/TMP
RUN cd /root/TMP && git clone https://github.com/neovim/neovim --depth 1 -b v0.10.0
RUN cd /root/TMP/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install
RUN rm -rf /root/TMP
RUN ln -s nvim /usr/local/bin/vi

EXPOSE 8080
CMD ["tail", "-f", "/dev/null"]
