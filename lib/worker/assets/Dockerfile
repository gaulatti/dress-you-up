# Use Ubuntu as the base image
FROM public.ecr.aws/ubuntu/ubuntu:latest

# Update Package List and install dependencies
RUN apt-get update && \
    apt-get install -y wget software-properties-common curl gnupg uuid-runtime unzip

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Download and install Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Install Lighthouse CI CLI
RUN npm install -g lighthouse

# Create directory for Lighthouse CI configuration and set it as the working directory
WORKDIR /usr/src/app

# Add entrypoint script
COPY entrypoint.sh /usr/src/app/entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]