FROM mysql:5.7

ENV MYSQL_DATABASE swat

RUN mkdir -p /etc/certs
COPY certs/*.pem /etc/certs/
RUN chown -R mysql:mysql /etc/certs