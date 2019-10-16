# AlpineLinux with a glibc-2.29-r0 and python2
FROM python:2.7.16-alpine3.10

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1


RUN set -ex && \
    apk add --no-cache apr-dev=1.6.5-r0 make=4.2.1-r2 openssl-dev=1.1.1d-r0 gcc=8.3.0-r0 musl-dev=1.1.22-r3 && \
    #see https://stackoverflow.com/questions/11912878/gcc-error-gcc-error-trying-to-exec-cc1-execvp-no-such-file-or-directory
    apk add --no-cache build-base=0.5-r1 && \
    apk add --no-cache cyrus-sasl-dev=2.1.27-r3 linux-headers=4.19.36-r0 unixodbc-dev=2.3.7-r1 && \
    #see https://stackoverflow.com/a/38571314/1137529
    apk add --no-cache lapack-dev=3.8.0-r1 freetype-dev=2.10.0-r0 && \
    apk add --no-cache gfortran=8.3.0-r0


ENV \
    PATH=${PATH}:/usr/local/bin \
    GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc \
    GLIBC_VERSION=2.29-r0 \
    LANG=C.UTF-8

# do all in one step
RUN set -ex && \
    #Remarked by Alex \
    #apk -U upgrade && \
    #Alex added --no-cache
    #ca-certificates bash
    apk --no-cache add libstdc++=8.3.0-r0 curl=7.66.0-r0 bash=5.0.0-r0 && \
    #Added  by Alex \
    #Alex added --no-cache
    apk --no-cache add net-tools=1.60_git20140218-r2 nano=4.3-r0 && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    #Alex added --no-cache
    apk --no-cache add /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib
    #Alex fix
    #mkdir /opt

#Alex
#disable coloring for nano, see https://stackoverflow.com/a/55597765/1137529
RUN echo "syntax \"disabled\" \".\"" > ~/.nanorc; echo "color green \"^$\"" >> ~/.nanorc

#work-arround for nano
#Odd caret/cursor behavior in nano within SSH session,
#see https://github.com/Microsoft/WSL/issues/1436#issuecomment-480570997
ENV TERM eterm-color


#https://stackoverflow.com/questions/9510474/removing-pips-cache
#https://pip.pypa.io/en/stable/reference/pip_install/#caching
RUN mkdir -p /root/.config/pip
RUN echo "[global]" > /root/.config/pip/pip.conf; echo "no-cache-dir = false" >> /root/.config/pip/pip.conf; echo >> /root/.config/pip/pip.conf;

RUN set -ex && \
    ln -s /usr/local/bin/python /usr/bin/python && \
    ln -s /usr/local/bin/python2 /usr/bin/python2 && \
    ln -s /usr/local/bin/python2.7 /usr/bin/python2.7 && \
    ln -s /usr/local/bin/pip /usr/bin/pip && \
    ln -s /usr/local/bin/pip2 /usr/bin/pip2 && \
    ln -s /usr/local/bin/pip2.7 /usr/bin/pip2.7


#COPY conf/ /etc/

RUN set -ex && \
    pip install --upgrade pip==19.2.3 setuptools==41.2.0

RUN set -ex && \
    #https://github.com/pypa/pip/issues/6667
    pip install numpy==1.9.3
    #pip install -r /etc/requirements.txt

#Cleanup
RUN set -ex && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
WORKDIR /
#RUN apk del glibc-i18n make gcc musl-dev build-base gfortran
RUN rm -rf /var/cache/apk/*

#CMD ["python2"]
CMD ["/bin/sh"]
#CMD tail -f /dev/null


#docker rmi -f ipython2
#docker rm -f python2
#docker build --squash . -t ipython2
#docker run --name python2 -d ipython2
#smoke test
#docker exec -it $(docker ps -q -n=1) pip config list
#docker exec -it $(docker ps -q -n=1) bash
#docker tag ipython2 alexberkovich/alpine-python2:0.0.1
#docker push alexberkovich/alpine-python2
# EOF
