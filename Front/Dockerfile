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

# Flutter SDK 다운로드
RUN git clone https://github.com/flutter/flutter.git /flutter

# Flutter SDK 경로를 환경 변수로 추가
ENV PATH "$PATH:/flutter/bin"

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드 복사
COPY ./Front/music_palette /app

# 소스 코드 디렉토리로 이동
WORKDIR /app

# Flutter 앱 빌드를 위해 필요한 작업 디렉토리 설정
WORKDIR /app/Front/music_palette

# Flutter 앱 빌드
RUN flutter pub get && flutter build apk --release

# 실행 명령어
CMD ["flutter", "run", "--release"]
CMD ["flutter", "run", "--release"]
