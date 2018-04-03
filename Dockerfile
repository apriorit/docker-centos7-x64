FROM centos:7
MAINTAINER krytin <krytin.vitaly@apriorit.com>

RUN yum -y update && yum clean all
RUN yum -y update && yum clean all
#Install custom packages
RUN yum install -y epel-release

RUN yum groups mark convert
RUN yum groupinstall -y 'Development Tools'

RUN yum install -y clang clang-devel llvm-devel cmake3 cmake python-testtools python-pip wget

#install kernel headers 3.10 x64
RUN yum -y install kernel-devel && yum install -y kernel && ls -l /lib/modules
RUN wget http://nixos.org/releases/patchelf/patchelf-0.8/patchelf-0.8.tar.gz && tar xf patchelf-0.8.tar.gz && patchelf-0.8/configure && make install && rm -rf patchelf-0.8 && rm -f patchelf-0.8.tar.gz
RUN yum upgrade -y
RUN yum-builddep -y qemu-kvm
RUN yum install -y elfutils-libelf-devel
RUN yum install -y git autoconf

#gRPC
RUN git clone --recursive --branch release-0_14_1 --single-branch https://github.com/grpc/grpc
RUN cd grpc && make HAS_SYSTEM_OPENSSL_NPN=false HAS_SYSTEM_OPENSSL_ALPN=false && make install prefix=/opt/grpc \
&& cd third_party/protobuf/ && make install prefix=/opt/grpc
#*******************************************
