# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/base-main:gts as spacefin

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh main

COPY system_files/shared /

# Enable custom services
RUN systemctl --global enable bazaar.service
RUN systemctl enable flatpak-preinstall.service

RUN ostree container commit
RUN bootc container lint
