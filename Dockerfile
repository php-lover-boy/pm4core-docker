FROM alpine as copy
ARG PM_VERSION

WORKDIR /tmp
RUN wget https://github.com/ProcessMaker/processmaker/archive/refs/tags/v${PM_VERSION}.zip
RUN unzip v${PM_VERSION}.zip && rm -rf /code/pm4 && mv processmaker-${PM_VERSION} /code/pm4

FROM composer:1.7 as vendor
WORKDIR /code/pm4
COPY --from=copy /code/pm4 .
RUN composer install
COPY build-files/laravel-echo-server.json .

FROM node:lts-alpine as node
WORKDIR /code/pm4
COPY --from=vendor /code/pm4 .
RUN npm install --unsafe-perm=true && npm run dev

FROM processmaker/pm4-base:v4.1.20
WORKDIR /code/pm4
COPY --from=node /code/pm4 .
COPY build-files/init.sh .
CMD bash init.sh && supervisord --nodaemon
