# ---------------------------------------------------------------------
# Nemesis CI-only ArchISO builder (x86_64) -- not the user workstation.
# Docker must run with --privileged for the rootfs/mount build operations.
# ---------------------------------------------------------------------
FROM archlinux:base-devel

ENV LANG=C.UTF-8
RUN pacman -Syu --noconfirm --needed archiso grub git shellcheck file

WORKDIR /workspace
CMD ["/bin/bash", "docker/archiso/validate-build.sh"]
