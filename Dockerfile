FROM openshift/base-centos7

# This image provides an Apache+PHP environment for running PHP
# applications.

MAINTAINER Christopher Timberlake <game64@gmail.com>

EXPOSE 8000

ENV PHP_VERSION=7.0 \
    PATH=$PATH:/opt/rh/rh-php70/root/usr/bin

LABEL io.k8s.description="PHP 7" \
      io.k8s.display-name="PHP 7" \
      io.openshift.expose-services="8000:http" \
      io.openshift.tags="builder,php,php7,php70"

# Install PHP
#RUN curl 'https://setup.ius.io/' -o setup-ius.sh && \
 #   bash setup-ius.sh
#RUN rm setup-ius.sh
#RUN yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus \
#    php70u-cli \
#    php70u-gd \
#    php70u-imap \
 #   php70u-json \
#    php70u-mbstring \
#    php70u-mcrypt \
#    php70u-opcache \
#    php70u-pdo \
#    php70u-pdo \
#    php70u-xml
#RUN yum clean all -y

RUN yum install -y centos-release-scl && \
    yum-config-manager --enable centos-sclo-rh-testing && \
    INSTALL_PKGS="rh-php71 rh-php71-php-cli rh-php71-php-mysqlnd rh-php71-php-pgsql rh-php71-php-bcmath \
                  rh-php71-php-gd rh-php71-php-intl rh-php71-php-ldap rh-php71-php-mbstring rh-php71-php-pdo \
                  rh-php71-php-process rh-php71-php-soap rh-php71-php-opcache rh-php71-php-xml \
                  rh-php71-php-gmp rh-php71-php-pecl-apcu" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS --nogpgcheck && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./.s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
#COPY ./contrib/ /opt/app-root

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && \
    chmod -R ug+rwx /opt/app-root && \
    ln -s /opt/rh/rh-php71/root/usr/bin/pear  /usr/local/bin/pear && \
    ln -s /opt/rh/rh-php71/root/usr/bin/peardev  /usr/local/bin/peardev && \
    ln -s /opt/rh/rh-php71/root/usr/bin/pecl  /usr/local/bin/pecl && \
    ln -s /opt/rh/rh-php71/root/usr/bin/phar  /usr/local/bin/phar && \
    ln -s /opt/rh/rh-php71/root/usr/bin/phar.phar /usr/local/bin/phar.phar && \
    ln -s /opt/rh/rh-php71/root/usr/bin/php  /usr/local/bin/php && \
    ln -s /opt/rh/rh-php71/root/usr/bin/php-cgi /usr/local/bin/php-cgi && \
    ln -s /opt/rh/rh-php71/root/usr/bin/phpize  /usr/local/bin/phpize

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage