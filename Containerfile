ARG EDITION

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/existingperson08/arch-base-cachy:latest as spacefin

# ARG EDITION
# ENV EDITION=$EDITION

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

COPY system_files /
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /

RUN rm -f /.gitkeep

# Enable custom services
RUN systemctl --global enable bazaar.service
RUN systemctl enable brew-setup.service
RUN systemctl disable brew-upgrade.timer
RUN systemctl disable brew-update.timer
RUN systemctl enable first-run.service
RUN systemctl --global enable new-user-setup.service

LABEL containers.bootc 1
RUN bootc container lint
