FROM centos:7
MAINTAINER Volodymyr Stovba <netpanik@apriorit.com>

RUN yum -y update && yum clean all

#Install custom packages
RUN yum install -y epel-release

RUN yum groups mark convert
RUN yum groupinstall -y 'Development Tools'

RUN yum install -y git subversion wget vim-common gdb boost-devel libicu-devel zlib-devel openssl-devel libuuid-devel cryptopp-devel redhat-lsb-core rpmrebuild gtest-devel bison valgrind which patchelf

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
 
# grpc
RUN cd /tmp && git clone -b "v1.13.x" https://github.com/grpc/grpc && cd grpc && git submodule update --init && make && make install && cd third_party/protobuf && make install

RUN patchelf --set-rpath '$ORIGIN' /usr/local/lib/libgpr.so.6.0.0
RUN patchelf --set-rpath '$ORIGIN' /usr/local/lib/libgrpc_cronet.so.6.0.0
RUN patchelf --set-rpath '$ORIGIN' /usr/local/lib/libgrpc++_reflection.so.1.13.1
RUN patchelf --set-rpath '$ORIGIN' /usr/local/lib/libgrpc++.so.1.13.1
RUN patchelf --set-rpath '$ORIGIN' /usr/local/lib/libgrpc.so.6.0.0
RUN patchelf --set-rpath '$ORIGIN' /usr/local/lib/libgrpc++_unsecure.so.1.13.1
RUN patchelf --set-rpath '$ORIGIN' /usr/local/lib/libgrpc_unsecure.so.6.0.0

#golang
RUN cd /tmp && mkdir -p golang && cd golang && wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz && cd /tmp && rm -rf ./golang
ENV GOBIN=/usr/local/go/bin 
ENV PATH=$PATH:$GOBIN 
ENV GOPATH=/root/go 
ENV GOSRC=$GOPATH/src
RUN mkdir -p $GOSRC/github.com/golang && cd $GOSRC/github.com/golang && git clone https://github.com/golang/protobuf && cd protobuf && git checkout tags/v1.2.0 -b v1.2.0
RUN mkdir -p $GOSRC/github.com/grpc-ecosystem && cd $GOSRC/github.com/grpc-ecosystem && git clone https://github.com/grpc-ecosystem/grpc-gateway && cd grpc-gateway && git checkout tags/v1.11.2 -b v1.11.2
RUN cd $GOSRC/github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway && go install
RUN cd $GOSRC/github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger && go install
RUN cd $GOSRC/github.com/golang/protobuf/protoc-gen-go && go install

