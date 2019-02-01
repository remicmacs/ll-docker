# Using Ubuntu server
FROM ubuntu:bionic as common
# Full system upgrade
RUN apt update && apt -y upgrade

# Adding needed software
RUN apt install -y apt-utils \
curl \
git \
gnupg \
net-tools \
openssl

# Yarn installation
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt -y upgrade
RUN apt-get install -y -qq yarn

# Install nodejs LTS argon like in deployll.sh script but against
# requirements listing of repository.
# Setup script used is from NodeSource
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Base directory for the application
ENV WEBAPPROOT=${WEBAPPROOT:-/usr/local/ll-app}

# Git clone is here for rapid build test purposes. Copy down when it is
# working
RUN mkdir -p ${WEBAPPROOT}/
WORKDIR ${WEBAPPROOT}
RUN git clone https://github.com/LearningLocker/learninglocker.git
WORKDIR ${WEBAPPROOT}/learninglocker

# Installing dependancies
RUN yarn install

# Copying template configuration file.
# Replacement of secret and domain name.
ARG app_secret
ARG domain_name
COPY .env.template .env
ENV DOMAIN_NAME=${domain_name:-placeholder.name}
ENV APP_SECRET=${app_secret:-pleasechangetounique256bitstring}
RUN sed -i "s?APP_SECRET=?APP_SECRET=${APP_SECRET}?" .env
RUN sed -i "s/SITE_URL=http:\/\/placeholder\.domain/${DOMAIN_NAME}/" .env

RUN yarn build-all

########################################################################
#                                  API                                 #
########################################################################
# Same base image as builder
FROM ubuntu:bionic as api
RUN apt update && apt -y upgrade
RUN apt install -y apt-utils \
curl \
git \
gnupg \
net-tools \
openssl
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt -y upgrade
RUN apt-get install -y -qq yarn

# Copying bundle with dependencies
COPY --from=common /usr/local/ll-app /usr/local/ll-app

# Workdir is web root
ENV WEBAPPROOT=${WEBAPPROOT:-/usr/local/ll-app}
WORKDIR ${WEBAPPROOT}/learninglocker

# API Server command
CMD ["node", "api/dist/server"]

########################################################################
#                                Web UI                                #
########################################################################
# Same base image as builder
FROM ubuntu:bionic as ui
RUN apt update && apt -y upgrade
RUN apt install -y apt-utils \
curl \
git \
gnupg \
net-tools \
openssl
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt -y upgrade
RUN apt-get install -y -qq yarn

# Copying bundle with dependencies
COPY --from=common /usr/local/ll-app /usr/local/ll-app

# Workdir is web root
ENV WEBAPPROOT=${WEBAPPROOT:-/usr/local/ll-app}
WORKDIR ${WEBAPPROOT}/learninglocker

# UI delivery server
CMD ["node", "ui/dist/server"]

########################################################################
#                                Worker                                #
########################################################################
# Same base image as builder
FROM ubuntu:bionic as worker
RUN apt update && apt -y upgrade
RUN apt install -y apt-utils \
curl \
git \
gnupg \
net-tools \
openssl
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt -y upgrade
RUN apt-get install -y -qq yarn

# Copying bundle with dependencies
COPY --from=common /usr/local/ll-app /usr/local/ll-app

# Workdir is web root
ENV WEBAPPROOT=${WEBAPPROOT:-/usr/local/ll-app}
WORKDIR ${WEBAPPROOT}/learninglocker

# Worker process command.
CMD ["node", "worker/dist/server"]