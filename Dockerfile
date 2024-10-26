FROM ghcr.io/malteherrmann/changelog-utils:v1.2.0

WORKDIR /github/workspace

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
