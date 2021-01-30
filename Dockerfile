#
# Check out the SQLite git mirror and install all neccesary tools for building sqlite
#
FROM alpine:3 as repository

WORKDIR /usr/local/src

RUN true                                                            \
    && apk add --update-cache                                       \
        ca-certificates libc-dev git autoconf libtool make gcc tcl  \
    && git config --global advice.detachedHead false                \
    && git config --global color.ui false

# TODO: Actually use fossil...
RUN git clone --verbose https://github.com/sqlite/sqlite.git

#
# Build our no frills version of sqlite
#

FROM repository as no-frills-builder

WORKDIR /root

ARG SQLITE_VERSION=master
RUN true                                                                                    \
    && git clone --depth 1 --branch "$SQLITE_VERSION" file:///usr/local/src/sqlite ./sqlite \
    && ./sqlite/configure                                                                   \
    && make all                                                                             \
    && ./sqlite3 --version

#
# Package our no frills version of sqlite in a alpine container
#

FROM alpine:3 as sqlite

COPY --from=no-frills-builder /root/sqlite3 /usr/bin/sqlite3



