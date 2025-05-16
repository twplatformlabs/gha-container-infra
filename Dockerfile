FROM twdps/gha-container-base-image:0.2.1

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

ENV TERRAFORM_VERSION=1.8.3
ENV TERRAFORM_SHA256SUM=4ff78474d0407ba6e8c3fb9ef798f2822326d121e045577f80e2a637ec33f553
ENV TFLINT_VERSION=0.51.0
ENV TRIVY_VERSION=0.51.1
ENV TERRASCAN_VERSION=1.19.1
ENV AWSCLI_VERSION=1.32.25
ENV CHECKOV_VERSION=3.2.71
ENV COSIGN_VERSION=2.2.4

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# since twdps circleci remote docker images set the USER=cirlceci
# hadolint ignore=DL3004
RUN bash -c "echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories" && \
    apk add --no-cache \
        nodejs-current==21.7.2-r0 \
        npm==10.2.5-r0 \
        ruby==3.2.4-r0 \
        ruby-dev==3.2.4-r0 \
        ruby-webrick==1.8.1-r0 \
        ruby-bundler==2.4.15-r0 \
        python3==3.11.9-r0 \
        python3-dev==3.11.9-r0 \
        perl-utils==5.38.2-r0 \
        libffi-dev==3.4.4-r3 && \
    rm /usr/lib/python3.11/EXTERNALLY-MANAGED && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache-dir --upgrade pip==24.0 && \
    if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip ; fi && \
    ln -s /usr/bin/pydoc3 /usr/bin/pydoc && \
    pip install --no-cache-dir --no-binary \
        setuptools==69.5.1 \
        wheel==0.43.0 \
        invoke==2.2.0 \
        requests==2.31.0 \
        jinja2==3.1.3 \
        iam-credential-rotation==0.2.2 \
        checkov=="${CHECKOV_VERSION}" \
        awscli=="${AWSCLI_VERSION}" && \
    npm install -g \
        snyk@1.1291.0 \
        bats@1.11.0 && \
    sh -c "echo 'gem: --no-document' > /etc/gemrc" && \
    gem install \
        awspec:1.30.0 \
        inspec-bin:5.22.36 \
        json:2.7.2 && \
    curl -SLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    sha256sum -cs "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && rm "terraform_${TERRAFORM_VERSION}_SHA256SUMS" && \
    unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin && \
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
