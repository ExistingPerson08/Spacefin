# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx

# Base Image
FROM ghcr.io/ublue-os/bluefin:stable as spacefin
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh main && \

COPY build_files /

RUN ostree container commit
RUN bootc container lint
