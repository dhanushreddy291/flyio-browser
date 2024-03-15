FROM docker/buildx-bin as buildx

FROM docker:dind

RUN apk add bash pigz sysstat procps lsof

COPY etc/docker/daemon.json /etc/docker/daemon.json

COPY --from=buildx /buildx /root/.docker/cli-plugins/docker-buildx

COPY ./entrypoint ./entrypoint
COPY ./docker-entrypoint.d/* ./docker-entrypoint.d/

ENV DOCKER_TMPDIR=/data/docker/tmp

ENTRYPOINT ["./entrypoint"]

CMD ["dockerd", "-p", "/var/run/docker.pid"]
