# Environemnt to install flutter and build web
FROM debian:latest AS build-env

# install all needed stuff
RUN apt-get update && apt-get install -y curl git unzip

# create a non-root user
RUN useradd -ms /bin/bash flutteruser
USER flutteruser

# define variables
ARG FLUTTER_SDK=/usr/local/flutter
ARG FLUTTER_VERSION=3.10.5
ARG APP=/home/flutteruser/app/

#clone flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK
# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an environmental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# Start to run Flutter commands
# doctor to see if all was installed ok
RUN flutter doctor -v

# create folder to copy source code
RUN mkdir $APP
# copy source code to folder
COPY . $APP
# setup new folder as the working directory
WORKDIR $APP

# Run build: 1 - clean, 2 - pub get, 3 - build web
# Check if pubspec.yaml exists before running flutter clean
RUN test -f "pubspec.yaml" && flutter clean || echo "pubspec.yaml not found"

# Run flutter pub get and flutter build web
RUN flutter pub get && flutter build web

# specify the working directory for further commands
WORKDIR /app

# 실행 명령어
CMD ["flutter", "run", "--release"]
