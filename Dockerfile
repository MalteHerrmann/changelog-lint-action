FROM ghcr.io/malteherrmann/changelog-utils:v1.1.2

WORKDIR /github/workspace

COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
