FROM ghcr.io/malteherrmann/changelog-utils:latest

WORKDIR /github/workspace

COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
