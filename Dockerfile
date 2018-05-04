FROM openshift/base-centos7

# This image provides an Apache+PHP environment for running PHP
# applications.

MAINTAINER Christopher Timberlake <game64@gmail.com>

EXPOSE 8000

ENV PHP_VERSION=7.0 \
    PATH=$PATH:/opt/rh/rh-php70/root/usr/bin

LABEL io.k8s.description="PHP 7" \
      io.k8s.display-name="PHP 7" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,php,php7,php70"

# Install PHP
RUN curl 'https://setup.ius.io/' -o setup-ius.sh && \
    bash setup-ius.sh
RUN rm setup-ius.sh
RUN yum install -y --setopt=tsflags=nodocs --enablerepo=centosplus \
    php70u-cli \
    php70u-gd \
    php70u-imap \
    php70u-json \
    php70u-mbstring \
    php70u-mcrypt \
    php70u-opcache \
    php70u-pdo \
    php70u-pdo \
    php70u-xml
RUN yum clean all -y

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./.s2i/bin/ $STI_SCRIPTS_PATH

# Each language image can have 'contrib' a directory with extra files needed to
# run and build the applications.
#COPY ./contrib/ /opt/app-root

# In order to drop the root user, we have to make some directories world
# writeable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/app-root && \
    chmod -R ug+rwx /opt/app-root

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage