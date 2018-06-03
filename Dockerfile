# This work is derived, by Sammons, from:
#
# Copyright 2017 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM alpine:3.7

LABEL gocd.version="18.5.0" \
  description="GoCD server based on alpine linux" \
  maintainer="GoCD <go-cd-dev@googlegroups.com>" \
  gocd.full.version="0.18.5.0-6679" \
  gocd.git.sha="a54c3fd44ef9ccbab1b0d856a8d735929eab97f7"

# the ports that go server runs on
EXPOSE 8153 8154

# force encoding
ENV LANG=en_US.utf8

USER 1000:1000
USER root

RUN \
# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
  addgroup -g 1000 go && \
  adduser -D -u 1000 -s /bin/bash -G go go && \
# install dependencies and other helpful CLI tools
  apk --no-cache upgrade && \
  apk add --no-cache openjdk8-jre-base git mercurial subversion tini openssh-client bash su-exec curl && \
  mkdir -p /tmp && \
  mkdir -p /docker-entrypoint.d && \
  mkdir -p /go-server && \
  chown 1000:1000 /tmp && \
  chown 1000:1000 /docker-entrypoint.d && \
  chown 1000:1000 /go-server && \
# download the zip file
  mkdir -p /tmp && \
  curl --fail --location --silent --show-error "https://download.gocd.org/binaries/18.5.0-6679/generic/go-server-18.5.0-6679.zip" > /tmp/go-server.zip && \
# unzip the zip file into /go-server, after stripping the first path prefix
  unzip /tmp/go-server.zip -d /tmp && \
  rm /tmp/go-server.zip && \
  mv -f /tmp/go-server-18.5.0/* /go-server/ && \
  chown -R 1000:1000 /go-server

COPY --chown=1000:1000 logback-include.xml /go-server/config/logback-include.xml
COPY --chown=1000:1000 install-gocd-plugins /usr/local/sbin/install-gocd-plugins
COPY --chown=1000:1000 git-clone-config /usr/local/sbin/git-clone-config

USER 1000:1000

ADD docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
