FROM rust:1.59.0-alpine3.15 as builder

ADD . /build
RUN apk add --no-cache git musl-dev
WORKDIR /build/veloren
ENV RUST_BACKTRACE=1
RUN cargo build --release --bin veloren-server-cli
RUN export GITFILES=$(dirname $(find /build/veloren/target/debug/ -name "githash") && \
    cp $GITFILES/git* /build/veloren/target/debug/

FROM alpine:3.15 as server
ARG VELOREN_VERSION=unknown
ARG VELOREN_COMMIT=unknown

COPY --from=builder /build/veloren/target/release/veloren-server-cli /opt/veloren/veloren-server-cli
COPY --from=builder /build/veloren/target/release/git* /opt/veloren/
COPY --from=builder /build/veloren/assets/common /opt/veloren/assets/common
COPY --from=builder /build/veloren/assets/server /opt/veloren/assets/server
COPY --from=builder /build/veloren/assets/world /opt/veloren/assets/world

VOLUME /opt/veloren/userdata
ENV VELOREN_VERSION=${VELOREN_VERSION} VELOREN_COMMIT=${VELOREN_COMMIT}
ENV VELOREN_USERDATA=/opt/veloren/userdata OUT_DIR=/opt/veloren/
EXPOSE 14004 14005
CMD "/opt/veloren/veloren-server-cli"
