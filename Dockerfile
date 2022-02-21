FROM debian:bullseye-slim as builder

ADD ./veloren /build
WORKDIR /build
RUN apt-get install \
    libglib2.0-dev \
    libasound2-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libatk1.0-dev \
    libgtk-3-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libudev-dev \
    libxkbcommon-x11-dev \
    libxcb-xkb-dev
RUN cargo build --release --bin veloren-server-cli


FROM debian:bullseye-slim as server

COPY --from=builder /build/veloren-server-cli /opt/veloren-server-cli
COPY --from=builder /build/assets/common /opt/assets/common
COPY --from=builder /build/assets/server /opt/assets/server
COPY --from=builder /build/assets/world /opt/assets/world

EXPOSE 14004 14005
CMD "/opt/veloren-server-cli"
