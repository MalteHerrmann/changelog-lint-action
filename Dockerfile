FROM ghcr.io/malteherrmann/changelog-utils:latest

WORKDIR /github/workspace

CMD ["lint"]
