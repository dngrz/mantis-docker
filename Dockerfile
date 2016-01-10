FROM centos:6
MAINTAINER itspoma <itspoma@gmail.com>

ENV MANTIS_VERSION 1.2.19

RUN yum clean all \
 && yum install -y git curl mc tar

# apache2
RUN yum install -y httpd

# configure the httpd
RUN sed 's/#ServerName.*/ServerName demo/' -i /etc/httpd/conf/httpd.conf \
 && sed 's/#EnableSendfile.*/EnableSendfile off/' -i /etc/httpd/conf/httpd.conf

# put vhost config for httpd
ADD ./environment/httpd/mantis.conf /etc/httpd/conf.d/mantis.conf

# php 5.5
RUN rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm \
    && yum install -y php55w php55w-pdo php55w-mysql php55w-intl

# configure the php.ini
RUN echo "" >> /etc/php.ini \
 && sed 's/;date.timezone.*/date.timezone = Europe\/Kiev/' -i /etc/php.ini \
 && sed 's/^display_errors.*/display_errors = On/' -i /etc/php.ini \
 && sed 's/^display_startup_errors.*/display_startup_errors = On/' -i /etc/php.ini \
 && sed 's/^upload_max_filesize.*/upload_max_filesize = 8M/' -i /etc/php.ini

ENV MYSQL_USER root

# mysql install
RUN yum install -y mysql mysql-server \
 && service mysqld restart \
 && /usr/bin/mysqladmin -u ${MYSQL_USER} password 'root' \
 && mysql -u ${MYSQL_USER} -proot -e "SHOW DATABASES;"

# mantis env vars
ENV MANTIS_URL http://jaist.dl.sourceforge.net/project/mantisbt/mantis-stable/${MANTIS_VERSION}/mantisbt-${MANTIS_VERSION}.tar.gz
ENV MANTIS_FILE mantisbt.tar.gz
ENV MANTIS_DIR /var/www/mantis

# mantis download & install
RUN mkdir -p ${MANTIS_DIR} \
 && cd ${MANTIS_DIR} \
 && curl -fSL ${MANTIS_URL} -o ${MANTIS_FILE} \
 && tar -xz --strip-components=1 -f ${MANTIS_FILE} \
 && rm -rf ${MANTIS_FILE} \
 && chmod 0777 -R /var/www/mantis

WORKDIR /shared

CMD ["/bin/bash", "/shared/environment/init.sh"]