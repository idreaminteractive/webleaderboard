FROM gitpod/workspace-full:2024-12-04-13-05-19
RUN sudo apt-get update && sudo apt-get install -y docker-buildx-plugin sqlite wget inotify-tools

# may need this for the building of things
# # Install go for sqlc tooling
# ENV GO_VERSION=1.23.4
# # For ref, see: https://github.com/gitpod-io/workspace-images/blob/61df77aad71689504112e1087bb7e26d45a43d10/chunks/lang-go/Dockerfile#L10
# ENV GOPATH=$HOME/go-packages
# ENV GOROOT=$HOME/go
# ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH
# RUN curl -fsSL https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz | tar xzs \
#     && printf '%s\n' 'export GOPATH=/workspace/go' \
#                       'export PATH=$GOPATH/bin:$PATH' > $HOME/.bashrc.d/300-go

RUN brew install asdf

RUN export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"
RUN asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
RUN asdf plugin-add rebar https://github.com/Stratus3D/asdf-rebar.git
RUN asdf plugin-add gleam

# install our versions
ENV GLEAM_VERSION=1.7.0
ENV ERLANG_VERSION=27.1.2
ENV REBAR_VERSION=3.24.0
RUN echo "gleam ${GLEAM_VERSION}\nerlang ${ERLANG_VERSION}\nrebar ${REBAR_VERSION}" | tee -a .tool-versions
RUN asdf install 
RUN echo 'export PATH=$PATH:/$HOME/.asdf/shims' >> .bashrc

# fly
RUN curl -L https://fly.io/install.sh | sh
ENV FLYCTL_INSTALL="/home/gitpod/.fly"
ENV PATH="$FLYCTL_INSTALL/bin:$PATH"

# install sqlc
RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
# json generator to act as an intermediary to gleam
RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc-gen-json@latest


# dbmate 
RUN sudo curl -fsSL -o /usr/local/bin/dbmate https://github.com/amacneil/dbmate/releases/latest/download/dbmate-linux-amd64
RUN sudo chmod +x /usr/local/bin/dbmate


# watch exec
RUN brew install watchexec

# install taskfile
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin


# install doppler locally.
RUN (curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh || wget -t 3 -qO- https://cli.doppler.com/install.sh) | sudo sh

# maybe
# RUN go install github.com/mailhog/MailHog@latest


# alias all the things
RUN echo 'alias home="cd ${GITPOD_REPO_ROOT}"' | tee -a ~/.bashrc ~/.zshrc

