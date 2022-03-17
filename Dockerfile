FROM alpine:latest

ARG version=1.1.1

RUN wget https://install.speedtest.net/app/cli/ookla-speedtest-${version}-linux-x86_64.tgz
RUN tar -xvf ookla-speedtest-${version}-linux-x86_64.tgz
RUN rm -rf ookla-speedtest-${version}-linux-x86_64.tgz speedtest.5 speedtest.md

RUN apk update
RUN apk add curl
RUN apk add jq

COPY ./speedtest.sh .

CMD ./speedtest.sh