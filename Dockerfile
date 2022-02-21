FROM rust:1.58.1-slim-bullseye as builder

ADD . /build
WORKDIR /build/veloren
ENV RUST_BACKTRACE=1
RUN cargo build --release --bin veloren-server-cli

FROM debian:bullseye-slim as server
ARG VELOREN_VERSION=unknown
ARG VELOREN_COMMIT=unknown

COPY --from=builder /build/veloren/target/release/veloren-server-cli /opt/veloren-server-cli
COPY --from=builder /build/veloren/assets/common /opt/assets/common
COPY --from=builder /build/veloren/assets/server /opt/assets/server
COPY --from=builder /build/veloren/assets/world /opt/assets/world

VOLUME /opt/userdata
ENV VELOREN_USERDATA=/opt/userdata VELOREN_VERSION=${VELOREN_VERSION} VELOREN_COMMIT=${VELOREN_COMMIT}
EXPOSE 14004 14005
CMD "/opt/veloren-server-cli"
