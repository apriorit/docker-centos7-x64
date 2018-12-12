FROM centos:7
MAINTAINER Sergii Kusii <kusii.sergii@apriorit.com>

RUN yum -y update && yum clean all && \
    yum install -y kernel kernel-devel
