# Use Alpine Linux as the base image
FROM alpine:latest

# Install required packages
RUN apk add --no-cache curl tar wget docker

# Set environment variables
ENV KUBECTL_VERSION="v1.23.0"

# Download and install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/kubectl

# Start Docker daemon
CMD ["dockerd", "--host=unix:///var/run/docker.sock", "--host=tcp://0.0.0.0:2375"]

# Wait for Docker daemon to start
RUN sleep 5

# Run commands to check Docker status and move kubectl
RUN docker ps -a && ls -alrt /var/run/docker.sock 

# Set the entrypoint to an indefinite command to keep the container running
ENTRYPOINT ["tail", "-f", "/dev/null"]

# Mount Docker socket from host
VOLUME /var/run/docker.sock:/var/run/docker.sock
