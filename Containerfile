ARG DESKTOP
ARG EDITION
ARG BASE

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/${BASE}-main:43 as spacefin

ARG DESKTOP
ARG EDITION

ENV DESKTOP=$DESKTOP
ENV EDITION=$EDITION

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh "$DESKTOP" "$EDITION"

COPY system_files/shared /
COPY system_files/desktops/${DESKTOP} /
COPY system_files/editions/${EDITION} /

RUN rm -f /.gitkeep

# Enable custom services
RUN systemctl --global enable bazaar.service
RUN systemctl enable flatpak-preinstall.service

# Enable dconf update service on GTK desktops
RUN if "$DESKTOP" == "gnome"; then \
        systemctl enable dconf-update.service; \
    elif "$DESKTOP" == "budgie"; then \
        systemctl enable dconf-update.service; \
    fi

RUN ostree container commit
RUN bootc container lint
