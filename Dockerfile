FROM node:14.21.3 as builder

# 系统：Debian
RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN  apt-get clean
RUN apt-get install python
# Jenkins镜像：jenkins/jenkins:jdk17  系统：Alpine Linux
# RUN apk add g++ make python

WORKDIR '/app'
COPY ./package.json ./
RUN npm config set strict-ssl false
RUN npm i node-sass --sass_binary_site=https://npm.taobao.org/mirrors/node-sass/
RUN npm --registry=https://registry.npm.taobao.org install
RUN npm install
COPY . .
RUN npm run build:prod

FROM nginx
EXPOSE 9527
COPY nginx.conf /etc/nginx/
COPY --from=builder /app/dist /usr/share/nginx/html/
