ARG ESP_IDF_VERSION="v5.4.1"

FROM espressif/idf:${ESP_IDF_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update -y && apt-get install udev -y
RUN echo "source /opt/esp/idf/export.sh > /dev/null 2>&1" >> ~/.bashrc

ARG TARGETARCH
ARG GO_VERSION

RUN wget "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf "go${GO_VERSION}.linux-${TARGETARCH}.tar.gz"

ENV PATH="$PATH:/usr/local/go/bin"

ENTRYPOINT [ "/opt/esp/entrypoint.sh" ]
CMD ["/bin/bash"]