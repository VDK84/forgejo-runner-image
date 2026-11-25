FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Instal·lació d'eines essencials per a runners de CI/CD
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    jq \
    podman \
    openssh-client \
    unzip \
    tar \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Instal·lació del certificat CA arrel intern de Smallstep
COPY smallstep-root-ca.crt /usr/local/share/ca-certificates/smallstep-root-ca.crt
RUN chmod 644 /usr/local/share/ca-certificates/smallstep-root-ca.crt && update-ca-certificates

# Configuració de variables d'entorn per a NodeJS i OpenSSL per reconèixer la CA interna
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

WORKDIR /workspace

CMD ["/bin/bash"]
