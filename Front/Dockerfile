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

# Flutter SDK 설치
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/bin/flutter"

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드 복사
COPY ./ /app


# 소스 코드 디렉토리로 이동
WORKDIR /app/music_palette

# Flutter 앱 빌드
RUN flutter pub get && flutter build apk --release

# 실행 명령어
CMD ["flutter", "run", "--release"]
