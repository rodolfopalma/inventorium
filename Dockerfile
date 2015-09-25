FROM ubuntu
MAINTAINER Rodolfo Palma Otero <rpalmaotero@gmail.com>

RUN apt-get update
RUN apt-get -y upgrade

# Install Node
RUN apt-get install -y nodejs npm

# Install dependencies
ADD package.json package.json
RUN npm install --production

# Add files
ADD private/ private/
ADD public/ public/

# Create empty folders
RUN mkdir results
RUN mkdir uploads

# Run server
ENV NODE_ENV "production"
EXPOSE 5100
CMD ["nodejs", "private/server.js"]
