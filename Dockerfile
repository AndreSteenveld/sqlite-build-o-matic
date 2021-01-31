#
# Get started with all the tools we need to build SQLite
#
FROM alpine:3 as builder

WORKDIR /root

RUN true                                        \
    && apk add --update-cache                   \
        libc-dev autoconf libtool make gcc tcl  \
    && mkdir --parents /root/src /root/build /root/install 

#
#
#
FROM builder as no-frills-builder

COPY /* /root/src

ARG SQLITE_VERSION=master
RUN true                            \
    && cd build ; ../src/configure  \
    && make install DESTDIR=$( realpath ../install )

#
# The image we're going to release
#
FROM alpine:3 as sqlite

ENTRYPOINT /usr/local/bin/sqlite3
COPY --from=no-frills-builder /root/install/ /
