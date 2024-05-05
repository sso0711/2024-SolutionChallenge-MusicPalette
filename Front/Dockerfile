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
    && rm -rf /var/lib/apt/lists/*

# 환경 변수 설정: Flutter SDK 경로 및 버전
ENV FLUTTER_SDK="/usr/local/flutter"
ENV FLUTTER_VERSION="stable"

#clone flutter
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_SDK

# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드 복사
COPY music_palette /app

# Flutter 앱 빌드
RUN flutter pub get && flutter build apk --release

# 실행 명령어
CMD ["flutter", "run", "--release"]
