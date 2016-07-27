FROM centos:7
MAINTAINER petrov <petrov@apriorit.com>
RUN yum -y update && yum clean all

#Install custom packages
RUN yum install -y epel-release

RUN yum groups mark convert
RUN yum groupinstall -y 'Development Tools'

RUN yum install -y clang clang-devel llvm-devel cmake3 cmake subversion python-testtools python-pip wget
RUN yum install -y qt-creator protobuf-compiler graphviz libxml2-devel libxslt-devel
RUN yes | pip install checksumdir

#bzip2 need for bulding of boost iostream library
RUN yum -y install bzip2 bzip2-devel


#building and installing of clang c++ library for better c++11 support
# http://stackoverflow.com/questions/25840088/how-to-build-libcxx-and-libcxxabi-by-clang-on-centos-7/25840107#25840107
#*******************************************
# Build libcxx without libcxxabi

RUN libcxx="libcxx-3.8.1.src"
RUN libcxxabi="libcxxabi-3.8.1.src"

RUN wget "http://llvm.org/releases/3.8.1/$libcxx.tar.xz"
RUN tar xf "$libcxx.tar.xz"
RUN cd $libcxx
# It is not recommended to build libcxx in the source root directory.
# So, we make a tmp directory.
RUN mkdir tmp
RUN cd tmp
# Specifying CMAKE_BUILD_TYPE to Release shall generate performance optimized code.
# Please specify the absolute paths to clang and clang++ to CMAKE_C_COMPILER and DCMAKE_CXX_COMPILER,
# because CMake (ver. 2.8.12 - 3.0.x) has a bug ... See http://www.cmake.org/Bug/view.php?id=15156
# The CMAKE_INSTALL_PREFIX changes the install path from the default /usr/local to /usr.
RUN cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ ..
RUN make install
# clang/clang++ compiled executables seem to not find libc++ in /usr/lib, but /lib64.
# Use symbolic link to solve this problem.
RUN ln -s /usr/lib/libc++.so.1 /lib64
RUN cd ..
RUN rm tmp -rf
RUN cd ..

# Build libcxxabi with libc++
#svn co http://llvm.org/svn/llvm-project/libcxxabi/tags/RELEASE_381/final libcxxabi
RUN wget "http://llvm.org/releases/3.8.1/$libcxxabi.tar.xz"
RUN tar xf "$libcxxabi.tar.xz"
RUN cd $libcxxabi
RUN mkdir tmp
RUN cd tmp
# Without -DCMAKE_CXX_FLAGS="-std=c++11", clang++ seems to use c++03, so libcxxabi which seems to be written in C++11 can't be compiled. It could be a CMakeLists.txt bug of libcxxabi.
RUN cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_CXX_FLAGS="-std=c++11" -DLIBCXXABI_LIBCXX_INCLUDES=../../$libcxx/include ..
RUN make install
# clang/clang++ compiled executables seem to not find libc++ in /usr/lib, but /lib64.
# Use symbolic link to solve this problem.
RUN ln -s /usr/lib/libc++abi.so.1 /lib64
RUN cd ../..

# Build libcxx with libcxxabi
RUN cd $libcxx
RUN mkdir tmp
RUN cd tmp
# This time, we want to compile libcxx with libcxxabi, so we have to specify LIBCXX_CXX_ABI=libcxxabi and the path to libcxxabi headers, LIBCXX_LIBCXXABI_INCLUDE_PATHS.
RUN cmake3 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DLIBCXX_CXX_ABI=libcxxabi -DLIBCXX_CXX_ABI_INCLUDE_PATHS=../../$libcxxabi/include ..
RUN make install
RUN cd ../..

#clear all
RUN rm -rf $libcxx $libcxxabi
#*******************************************
