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

# Install RVM & Ruby 2.5.8
RUN gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
        && curl -sSL https://raw.githubusercontent.com/rvm/rvm/stable/binscripts/rvm-installer | bash -s stable --ruby=2.5.8 \
        && /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem install bundler --no-format-executable" \
        && echo "source /usr/local/rvm/scripts/rvm" >> ~/.bashrc

# Install dumb-init
RUN wget -O /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
        && chmod +x /usr/bin/dumb-init

# Install configgin
# The configgin version is hardcoded here so a commit is generated when the version is bumped.
RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem install configgin --version=0.20.3"

RUN apt-get -y install jq rsync fuse

# Add additional configuration and scripts
ADD monitrc.erb /opt/fissile/monitrc.erb

ADD post-start.sh /opt/fissile/post-start.sh
RUN chmod ug+x /opt/fissile/post-start.sh

ADD rsyslog_conf/etc /etc/
