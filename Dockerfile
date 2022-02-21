FROM rust:1.58.1-alpine3.15 as builder

RUN apk add --no-cache git musl-dev && git clone https://gitlab.com/veloren/veloren
WORKDIR /veloren
ENV RUST_BACKTRACE=1
RUN cargo build --release --bin veloren-server-cli

FROM alpine:3.15 as server

COPY --from=builder /veloren/target/release/veloren-server-cli /opt/veloren-server-cli
COPY --from=builder /veloren/assets/common /opt/assets/common
COPY --from=builder /veloren/assets/server /opt/assets/server
COPY --from=builder /veloren/assets/world /opt/assets/world

VOLUME /opt/userdata
ENV VELOREN_USERDATA=/opt/userdata
EXPOSE 14004 14005
CMD "/opt/veloren-server-cli"
