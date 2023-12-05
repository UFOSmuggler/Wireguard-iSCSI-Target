FROM linuxserver/wireguard:latest

ARG BUILD_DATE
ARG VERSION

LABEL build_version="Wireguard-iSCSI-Target version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="UFOSmuggler"

RUN apk update
RUN apk add --no-cache targetcli
RUN rm -rf /var/cache/apk/*

COPY /root /

ENV LSIO_FIRST_PARTY false
