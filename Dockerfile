FROM continuumio/miniconda3:latest

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini
RUN chmod +x /tini

RUN apt-get update\
  && apt-get install --no-install-recommends htop default-libmysqlclient-dev libsnappy-dev liblzma-dev -y patch \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


RUN rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

COPY requirements.txt /tmp/

ARG DEV_APT_DEPS="\
     build-essential"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
           ${DEV_APT_DEPS}\
  && pip install --upgrade pip \
  && pip install --use-deprecated=legacy-resolver --no-cache-dir -r /tmp/requirements.txt \
  && rm -f /tmp/requirements.txt /tmp/constraints.txt\
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/facebookresearch/pysparnn.git pysparnn
RUN pip install -e pysparnn

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/tini", "--", "/entrypoint.sh"]
