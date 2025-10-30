#
# Dockerfile for Broadcom (LSI) SAS
#

#
# Runtime stage
#
FROM debian:bookworm-slim
LABEL maintainer="haeho7 <i@demo.com>"

ARG STORCL_DOWNLOAD_URL=https://docs.broadcom.com/docs-and-downloads/host-bus-adapters/host-bus-adapters-common-files/sas_sata_nvme_12g_p35/STORCLI_SAS3.5_P35.zip
ARG SAS3IRCU_DOWNLOAD_URL=https://docs.broadcom.com/docs-and-downloads/host-bus-adapters/host-bus-adapters-common-files/sas_sata_12g_p16_point_release/SAS3IRCU_P16.zip

ARG TARGETARCH
ENV ARCH=${TARGETARCH}

RUN apt-get update \
  && apt-get install --no-install-recommends -y tzdata bash-completion nano tree wget curl ca-certificates unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# download and install
RUN cd /tmp \
  && curl -sSL -o storcl.zip $STORCL_DOWNLOAD_URL \
  && unzip storcl.zip \
  && TARGET_ARCH="${ARCH:-$(dpkg --print-architecture)}" \
  && case "$TARGET_ARCH" in \
       amd64) dpkg -i STORCLI_SAS3.5_P35/univ_viva_cli_rel/Unified_storcli_all_os/Ubuntu/storcli*.deb;; \
       arm64) dpkg -i STORCLI_SAS3.5_P35/univ_viva_cli_rel/Unified_storcli_all_os/ARM/Linux/storcli*.deb;; \
       *) echo "Unsupported architecture: $TARGET_ARCH" && exit 1 ;; \
     esac \
  && [ -f /opt/MegaRAID/storcli/storcli64 ] && ln -sf /opt/MegaRAID/storcli/storcli64 /usr/local/bin/storcli64 || true \
  && rm -rf /tmp/*

RUN cd /tmp \
  && curl -sSL -o sas3ircu.zip $SAS3IRCU_DOWNLOAD_URL \
  && unzip sas3ircu.zip \
  && TARGET_ARCH="${ARCH:-$(dpkg --print-architecture)}" \
  && case "$TARGET_ARCH" in \
       amd64) install SAS3IRCU_P16/sas3ircu_linux_x64_rel/sas3ircu /usr/local/bin/sas3ircu;; \
       arm64) install SAS3IRCU_P16/sas3ircu_linux_arm_rel/sas3ircu /usr/local/bin/sas3ircu;; \
       *) echo "Unsupported architecture: $TARGET_ARCH" && exit 1 ;; \
     esac \
  && chmod +x /usr/local/bin/sas3ircu \
  && rm -rf /tmp/*

WORKDIR /usr/local/bin

#ENTRYPOINT []
CMD ["bash"]
