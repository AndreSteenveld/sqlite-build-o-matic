#
# Check out the SQLite git mirror and install all neccesary tools for building sqlite
#
FROM alpine:3 as repository

WORKDIR /usr/local/src

RUN true                                                            \
    && apk add --update-cache                                       \
        ca-certificates libc-dev git autoconf libtool make gcc tcl  \
    && git config --global advice.detachedHead false                \
    && git config --global color.ui false                           \
    && mkdir --parents /root/src /root/build /root/install

# TODO: Actually use fossil...
RUN git clone --verbose https://github.com/sqlite/sqlite.git

#
# Build our no frills version of sqlite
#

FROM repository as no-frills-builder

WORKDIR /root

ARG SQLITE_VERSION=master
RUN true                                                                                    \
    && git clone --depth 1 --branch "$SQLITE_VERSION" file:///usr/local/src/sqlite ./src    \
    && ( cd ./build ; ../src/configure && make install DESTDIR=$( realpath ../install ) )   \
    && tar --create --verbose --file ./sqlite.package.tar --directory ./install/ .

#
# Package our no frills version of sqlite in a alpine container
#

FROM alpine:3 as sqlite

ENTRYPOINT [ "sqlite3" ]

# Maybe we can mount this using buildkit?
COPY --from=no-frills-builder /root/sqlite.package.tar /root/sqlite.package.tar
RUN tar --extract --verbose --file /root/sqlite.package.tar --directory / && rm /root/sqlite.package.tar



