# 사용할 이미지 선택
FROM python:3.8-slim

# 필요한 라이브러리 설치
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 파이썬 라이브러리 설치
RUN pip install flask pillow requests google-cloud

# 작업 디렉토리 설정
WORKDIR /app

# 애플리케이션 소스 코드 복사
COPY . /app

# 애플리케이션 실행
CMD ["python", "app.py"]
