FROM centos:7
MAINTAINER petrov <petrov@apriorit.com>
RUN yum -y update && yum clean all

# Install custom packages
