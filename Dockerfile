# Use the official Node 8 image.
# https://hub.docker.com/_/node 
FROM node:8

ADD ./kube/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

# Create and change to the app directory.
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure both package.json AND package-lock.json are copied.
# Copying this separately prevents re-running npm install on every code change.
COPY package*.json ./

# Install production dependencies.
RUN npm install --only=production

# Copy local code to the container image.
COPY config.js .
COPY index.html .
COPY configuration .
COPY configure.sh .
COPY config/service-template service-template

ARG DOCKER_USER
ENV DOCKER_USER=$DOCKER_USER

# Configure and document the service HTTP port.
ENV PORT 8080
EXPOSE $PORT

# Run the web service on container startup.
CMD [ "npm", "start" ]

