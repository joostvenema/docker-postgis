FROM mdillon/postgis:9.5
MAINTAINER Joost Venema <joost.venema@kadaster.nl>

ENV ORACLE_MAJOR 12.1
ENV ORACLE_VERSION 12.1.0.2.0-1

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  build-essential make curl ca-certificates libcurl4-gnutls-dev \
  shapelib libproj-dev libproj0 proj-data libgeos-3.4.2 libgeos-c1 libgeos-dev \
  postgresql-client-common libpq-dev \
  postgresql-server-dev-9.5 \
  alien \
  zip \
  libaio1

WORKDIR /tmp

COPY oracle/oracle-instantclient${ORACLE_MAJOR}-basic-${ORACLE_VERSION}.x86_64.rpm \
     oracle/oracle-instantclient${ORACLE_MAJOR}-sqlplus-${ORACLE_VERSION}.x86_64.rpm \
     oracle/oracle-instantclient${ORACLE_MAJOR}-jdbc-${ORACLE_VERSION}.x86_64.rpm \
     oracle/oracle-instantclient${ORACLE_MAJOR}-devel-${ORACLE_VERSION}.x86_64.rpm ./

RUN alien -i oracle-instantclient${ORACLE_MAJOR}-basic-${ORACLE_VERSION}.x86_64.rpm && \
    alien -i  oracle-instantclient${ORACLE_MAJOR}-sqlplus-${ORACLE_VERSION}.x86_64.rpm && \
    alien -i  oracle-instantclient${ORACLE_MAJOR}-jdbc-${ORACLE_VERSION}.x86_64.rpm && \
    alien -i  oracle-instantclient${ORACLE_MAJOR}-devel-${ORACLE_VERSION}.x86_64.rpm

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/oracle/12.1/client64/lib
ENV PATH $PATH:/usr/lib/oracle/12.1/client64/bin
ENV ORACLE_HOME /usr/lib/oracle/12.1/client64/bin

RUN curl http://download.osgeo.org/gdal/2.1.2/gdal-2.1.2.tar.gz | tar zxv -C /tmp && \
cd /tmp/gdal-2.1.2 && \
./configure \
--prefix=/usr \
--with-threads \
--with-hide-internal-symbols=yes \
--with-rename-internal-libtiff-symbols=yes \
--with-rename-internal-libgeotiff-symbols=yes \
--with-libtiff=internal \
--with-geotiff=internal \
--with-geos \
--with-pg \
--with-curl \
--with-static-proj4=yes \
--with-ecw=no \
--with-grass=no \
--with-hdf5=no \
--with-java=no \
--with-mrsid=no \
--with-perl=no \
--with-python=no \
--with-webp=no \
--with-xerces=no && \
make -j $(grep --count ^processor /proc/cpuinfo) && \
make install

ADD https://github.com/laurenz/oracle_fdw/archive/master.zip ./oracle_fdw.zip
ADD https://github.com/pramsey/pgsql-ogr-fdw/archive/master.zip ./ogr_fdw.zip

RUN unzip -q oracle_fdw.zip
RUN unzip -q ogr_fdw.zip

WORKDIR /tmp/oracle_fdw-master

RUN make && \
    make install

WORKDIR /tmp/pgsql-ogr-fdw-master

RUN make && \
    make install
