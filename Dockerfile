FROM centos:7
MAINTAINER Volodymyr Stovba <netpanik@apriorit.com>

RUN yum -y update && yum clean all

#Install custom packages
RUN yum install -y epel-release

RUN yum groups mark convert
RUN yum groupinstall -y 'Development Tools'

RUN yum install -y git subversion wget vim-common gdb boost-devel libicu-devel zlib-devel openssl-devel libuuid-devel cryptopp-devel redhat-lsb-core rpmrebuild gtest-devel

RUN yum clean all

RUN cd /tmp && wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz && tar xf cmake-3.14.5.tar.gz && cd /tmp/cmake-3.14.5 && \
./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release && make && make install && cd ../ && rm -rf cmake-3.14.5 && rm -rf cmake-3.14.5.tar.gz

RUN curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo

#Install MS ODBC Driver and Libraries

RUN yum -y install unixODBC-devel

RUN ACCEPT_EULA=Y yum -y install msodbcsql17

RUN ACCEPT_EULA=Y yum -y install mssql-tools

#Install postgres odbc and replace relative path by full path to odbc driver (fix not found odbc driver error)
RUN yum install -y postgresql-odbc postgresql-contrib 

COPY resources /srv/resources

RUN odbcinst -i -d -f /srv/resources/postgresql.ini

#Build POCO library
RUN cd /tmp && git clone -b "poco-1.9.0" https://github.com/pocoproject/poco.git && cd poco/ && mkdir cmake-build && cd cmake-build && \
sed -i '/project(Poco)/a SET(CMAKE_INSTALL_RPATH "\$ORIGIN")' ../CMakeLists.txt && cmake .. -DCMAKE_BUILD_TYPE=RELEASE && cmake --build . && \
make DESTDIR=/opt/apriorit-poco all install
 




