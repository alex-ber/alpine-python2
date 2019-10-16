## alpine-python2


This is Alpine Linux based Python 2.7 installation.
It contains GLIBS, C++ compiler, Fortrant compiler, openSSL, ODBC driver, etc.
It contains only numpy (that is Fortran-based and is compiled inside docker image).

You can extends this docker image and simply add

FROM alexberkovich/alpine-python2:latest
COPY conf/requirements.txt etc/requirements.txt
RUN pip install -r  etc/requirements.txt




