FROM ubuntu:16.04

MAINTAINER Gerben Venekamp "gerben.venekamp@surfsara.nl"

RUN apt-get update -qq
RUN apt-get install -y apt-utils
RUN apt-get install -y python python-pip wget libssl-dev
RUN pip install --upgrade pip
RUN pip install ansible
RUN pip install molecule

EXPOSE 443
