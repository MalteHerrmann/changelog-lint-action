FROM ghcr.io/malteherrmann/changelog-utils:v1.6.1

USER root
RUN apk add --no-cache git \
    && git config --system --add safe.directory /github/workspace

WORKDIR /github/workspace

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
