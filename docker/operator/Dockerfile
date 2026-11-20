# ---------------------------------------------------------------------
# Ephemeral Arch Linux operator build image. Source compilation occurs in
# separate unprivileged docker run; only mkarchiso requires --privileged.
# ---------------------------------------------------------------------
FROM archlinux:base-devel
ENV LANG=C.UTF-8
RUN pacman -Syu --noconfirm --needed archiso grub git file shellcheck \
    cargo rust pkgconf gtk4 gtk4-layer-shell webkitgtk-6.0 python curl \
    wayland-utils squashfs-tools xorriso
WORKDIR /workspace
CMD ["/bin/bash"]
