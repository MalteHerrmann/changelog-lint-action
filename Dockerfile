FROM ghcr.io/malteherrmann/changelog-utils:v1.5.0

WORKDIR /github/workspace

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
