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
    && rm -rf /var/lib/apt/lists/*

# 호스트 시스템에서 생성된 Flutter SDK를 Docker 컨테이너로 마운트
ARG FLUTTER_SDK_PATH=/path/to/host/flutter
VOLUME $FLUTTER_SDK_PATH:/flutter

# Flutter SDK 경로를 환경 변수로 추가
ENV PATH "$PATH:/flutter/bin"

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드 복사
COPY ./music_palette /app

# 소스 코드 디렉토리로 이동
WORKDIR /app/music_palette

# Flutter 앱 빌드
RUN flutter pub get && flutter build apk --release

# 실행 명령어
CMD ["flutter", "run", "--release"]
