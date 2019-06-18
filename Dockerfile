FROM centos:7
MAINTAINER Volodymyr Stovba <netpanik@apriorit.com>

RUN yum -y update && yum clean all

#Install custom packages
RUN yum install -y epel-release

RUN yum groups mark convert
RUN yum groupinstall -y 'Development Tools'

RUN yum install -y git subversion wget boost-devel libicu-devel zlib-devel openssl-devel libuuid-devel unixODBC-devel cryptopp-devel redhat-lsb-core

RUN yum clean all

RUN cd /tmp && wget https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz && tar xf cmake-3.14.5.tar.gz && cd /tmp/cmake-3.14.5 && \
./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release && make && make install && cd ../ && rm -rf cmake-3.14.5 && rm -rf cmake-3.14.5.tar.gz
 




