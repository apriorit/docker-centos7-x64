FROM centos:7
MAINTAINER Sergii Kusii <kusii.sergii@apriorit.com>

RUN yum -y update && \
    yum install -y kernel kernel-devel && \
    yum install -y cmake make gcc-c++ && \
    yum clean all
