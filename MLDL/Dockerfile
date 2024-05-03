# 사용할 이미지 선택
FROM node:latest

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 설치
RUN npm install

# 애플리케이션 소스코드 복사
COPY MLDL .

# 애플리케이션 실행
CMD ["node", "api.js"]
