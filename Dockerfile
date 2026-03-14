FROM ghcr.io/malteherrmann/changelog-utils:v1.6.1

WORKDIR /github/workspace

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
