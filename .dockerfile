# Use an official Ubuntu image as the base
FROM ubuntu:20.04

# Install NGINX and Jenkins dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    gnupg2 \
    lsb-release \
    sudo \
    curl \
    ubuntu-keyring \ 
    && apt-get clean

# Add Jenkins repo and install Jenkins
RUN curl -fsSL https://pkg.jenkins.io/jenkins.io.key | tee /etc/apt/trusted.gpg.d/jenkins.asc
RUN echo "deb http://pkg.jenkins.io/debian/ stable main" | tee -a /etc/apt/sources.list.d/jenkins.list 
RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null 
RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list


RUN apt-get update && apt-get install -y jenkins nginx

# Install supervisor to manage both services
RUN apt-get install -y supervisor

# Configure Supervisor to run both NGINX and Jenkins
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY nginx.conf  /etc/nginx/conf.d/default.conf
# Expose necessary ports
EXPOSE 8080 80

# Start Supervisor to run both NGINX and Jenkins
CMD ["/usr/bin/supervisord"]
