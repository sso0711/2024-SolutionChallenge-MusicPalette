# 기본 이미지 설정
FROM ubuntu:latest

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    xz-utils \
    libglu1-mesa \
    lib32stdc++6 \
    curl \
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

# 안드로이드 SDK 다운로드 및 설치
RUN wget -O sdk-tools-linux.zip https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip
RUN mkdir /android-sdk
RUN unzip -d /android-sdk sdk-tools-linux.zip
RUN rm sdk-tools-linux.zip

# ANDROID_HOME 환경 변수 설정
ENV ANDROID_HOME=/android-sdk

# SDK 라이선스 동의
RUN yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --licenses

# SDK 업데이트 및 필요한 패키지 설치
RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager --update
RUN $ANDROID_HOME/cmdline-tools/bin/sdkmanager "build-tools;31.0.0" "platform-tools" "platforms;android-31" "extras;android;m2repository" "extras;google;m2repository"

# Flutter SDK 다운로드
RUN git clone https://github.com/flutter/flutter.git /flutter

# Flutter SDK 경로를 환경 변수로 추가
ENV PATH="$PATH:/flutter/bin"

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드 복사
COPY ./music_palette /app

# 소스 코드 디렉토리로 이동
WORKDIR /app

# Flutter 앱 빌드를 위해 필요한 작업 디렉토리 설정
WORKDIR /app/music_palette

# Flutter 앱 빌드
RUN flutter pub get && flutter build apk --release

# 실행 명령어
CMD ["flutter", "run", "--release"]
