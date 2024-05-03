# base 이미지 (필수)
FROM node:latest

# 의존성 설치 전, 의존성 정보를 가져옴 
# (package.json의 변경이 없다면 npm install을 안 해도 되므로 캐시 재사용 & 의존성 설치 시간 줄이는 효과)
COPY package.json /app

# 의존성 설치
RUN npm install

# ADD로 파일/디렉터리 추가 가능

# 소스 코드 복사
COPY ./ /app

# 애플리케이션 실행
CMD ["node", "index.js"]
