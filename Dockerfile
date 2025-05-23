FROM twdps/gha-container-base-image:3.0.3

LABEL org.opencontainers.image.title="gha-container-infra" \
      org.opencontainers.image.description="Alpine-based github actions job container image" \
      org.opencontainers.image.documentation="https://github.com/ThoughtWorks-DPS/gha-container-infra" \
      org.opencontainers.image.source="https://github.com/ThoughtWorks-DPS/gha-container-infra" \
      org.opencontainers.image.url="https://github.com/ThoughtWorks-DPS/gha-container-infra" \
      org.opencontainers.image.vendor="ThoughtWorks, Inc." \
      org.opencontainers.image.authors="nic.cheneweth@thoughtworks.com" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.created="CREATED" \
      org.opencontainers.image.version="VERSION"

ENV TERRAFORM_VERSION=1.12.1
ENV TERRAFORM_SHA256SUM=dcaf8ba801660a431a6769ec44ba53b66c1ad44637512ef3961f7ffe4397ef7c
ENV TFLINT_VERSION=0.51.0
ENV TRIVY_VERSION=0.51.1
ENV TERRASCAN_VERSION=1.19.1
ENV AWSCLI_VERSION=1.32.25
ENV CHECKOV_VERSION=3.2.71
ENV COSIGN_VERSION=2.2.4

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Install system packages first
# hadolint ignore=DL3003,DL3004,DL4001,SC2035,DL3018
RUN bash -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.21/main' >> /etc/apk/repositories" && \
  apk add --no-cache \
        ruby \
        ruby-dev \
        ruby-webrick \
        ruby-bundler \
        python3 \
        python3-dev \
        perl-utils \
        libffi-dev

# Install Node.js separately
# hadolint ignore=DL3003,DL3004,DL4001,SC2035,DL3018
RUN apk add --no-cache \
        nodejs-current \
        npm

# Continue with Python setup
# hadolint ignore=DL3003,DL3004
RUN rm /usr/lib/python3.12/EXTERNALLY-MANAGED && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache-dir --upgrade pip==24.0

# Install Python packages
# hadolint ignore=DL3003,DL3004
RUN pip install --no-cache-dir --no-binary \
        setuptools==69.5.1 \
        wheel==0.43.0 \
        invoke==2.2.0 \
        requests==2.31.0 \
        jinja2==3.1.3 \
        iam-credential-rotation==0.2.2 \
        checkov=="${CHECKOV_VERSION}" \
        awscli=="${AWSCLI_VERSION}"

# Install Node.js packages
# hadolint ignore=DL3003,DL3004,DL3008,DL3059
RUN npm install -g \
        snyk@1.1291.0 \
        bats@1.11.0

# Install Ruby gems
# hadolint ignore=DL3003,DL3004
RUN sh -c "echo 'gem: --no-document' > /etc/gemrc" && \
    gem install \
        awspec:1.30.0 \
        inspec-bin:5.22.36 \
        json:2.7.2

# since twdps circleci remote docker images set the USER=cirlceci
# hadolint ignore=DL3004,DL3003,DL3059
RUN bash -c "echo 'http://dl-cdn.alpinelinux.org/alpine/v3.21/main' >> /etc/apk/repositories" && \
    curl -SLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    sha256sum -cs "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && rm "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    mv terraform /usr/local/bin && \
    rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    curl -SLO "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" > tflint_linux_amd64.zip && \
    unzip tflint_linux_amd64.zip -d /usr/local/bin && \
    rm tflint_linux_amd64.zip && \
    curl -LO "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" && \
    tar xzf "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" trivy && \
    mv trivy /usr/local/bin && rm "trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" && \
    curl -L https://github.com/tenable/terrascan/releases/download/v${TERRASCAN_VERSION}/terrascan_${TERRASCAN_VERSION}_Linux_x86_64.tar.gz --output terrascan_${TERRASCAN_VERSION}_Linux_x86_64.tar.gz && \
    tar -xf terrascan_${TERRASCAN_VERSION}_Linux_x86_64.tar.gz terrascan && \
    rm terrascan_${TERRASCAN_VERSION}_Linux_x86_64.tar.gz && \
    mv terrascan /usr/local/bin/terrascan && \
    curl -LO "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64" && \
    chmod +x cosign-linux-amd64 && mv cosign-linux-amd64 /usr/local/bin/cosign

    COPY inspec /etc/chef/accepted_licenses/inspec
