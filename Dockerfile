ARG base_image
FROM ${base_image}

ARG stemcell_version
RUN [ -n "$stemcell_version" ] || (echo "stemcell_version needs to be set"; exit 1)

LABEL stemcell-flavor=ubuntu
LABEL stemcell-version=${stemcell_version}

ENV SHELL /bin/bash

RUN ln -sf /bin/bash /bin/sh

# Install dirmngr
RUN apt-get -y install dirmngr time

# Install Ruby
ADD install-ruby.sh /tmp/install-ruby.sh
RUN chmod a+x /tmp/install-ruby.sh
RUN cd /tmp && ./install-ruby.sh && rm install-ruby.sh
RUN gem install bundler --no-format-executable

# Install dumb-init
RUN wget -O /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
        && chmod +x /usr/bin/dumb-init

# Install configgin
# The configgin version is hardcoded here so a commit is generated when the version is bumped.
RUN gem install configgin --version=0.20.3

RUN apt-get -y install jq rsync fuse

# Add additional configuration and scripts
ADD monitrc.erb /opt/fissile/monitrc.erb

ADD post-start.sh /opt/fissile/post-start.sh
RUN chmod ug+x /opt/fissile/post-start.sh

ADD rsyslog_conf/etc /etc/
