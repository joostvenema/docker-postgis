FROM postgres:9.5
MAINTAINER Mike Dillon <mike@appropriate.io>

ENV POSTGIS_MAJOR 2.2
ENV POSTGIS_VERSION 2.2.2+dfsg-1.pgdg80+1

RUN apt-get update
RUN apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository ppa:georepublic/pgrouting
RUN apt-get install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgis=$POSTGIS_VERSION \
           postgresql-server-dev-9.5 \
           postgresql-9.1-pgrouting \
           curl \
           gcc \
           ca-certificates \
           git \
           alien \
      && rm -rf /var/lib/apt/lists/*

# Get Oracle Client (this isn't the offical download location, but at least it works without logging in!)
RUN curl -O http://repo.dlt.psu.edu/RHEL5Workstation/x86_64/RPMS/oracle-instantclient12.1-basic-12.1.0.1.0-1.x86_64.rpm
RUN curl -O http://repo.dlt.psu.edu/RHEL5Workstation/x86_64/RPMS/oracle-instantclient12.1-devel-12.1.0.1.0-1.x86_64.rpm

# RPM to DEB
RUN alien -d *.rpm

# Install packages
RUN dpkg -i *.deb

# Setup Oracle environment
RUN echo "/usr/lib/oracle/12.1/client64/lib" > /etc/ld.so.conf.d/oracle.conf
ENV ORACLE_HOME /usr/lib/oracle/12.1/client64
ENV LD_LIBRARY_PATH /usr/lib/oracle/12.1/client64/lib

# Download and compile oracle_fdw
RUN git clone https://github.com/laurenz/oracle_fdw.git &&\
    cd oracle_fdw &&\
    make && make install &&\
    cd .. && rm -Rf oracle_fdw

# get compiled libraries recognized
RUN ldconfig

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
