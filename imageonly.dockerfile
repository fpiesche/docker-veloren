FROM alpine:3.15 as server
ARG VELOREN_VERSION=unknown
ARG VELOREN_COMMIT=unknown

COPY veloren/target/debug/veloren-server-cli /opt/veloren/veloren-server-cli
COPY veloren/target/debug/git* /opt/veloren/
COPY veloren/assets/common /opt/veloren/assets/common
COPY veloren/assets/server /opt/veloren/assets/server
COPY veloren/assets/world /opt/veloren/assets/world

VOLUME /opt/veloren/userdata
ENV VELOREN_VERSION=${VELOREN_VERSION} VELOREN_COMMIT=${VELOREN_COMMIT}
ENV VELOREN_USERDATA=/opt/veloren/userdata OUT_DIR=/opt/veloren/
EXPOSE 14004 14005
CMD "/opt/veloren/veloren-server-cli"
