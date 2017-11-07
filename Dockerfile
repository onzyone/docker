FROM centos:7

ENV PUPPET_AGENT_VERSION="5.3.3"
ENV PUPPET_MODULE_AZURE_VERSION="1.2.0"
ENV PUPPET_MODULE_AWS_VERSION="2.0.0"
ENV PUPPET_MODULE_STDLIB_VERSION="4.20.0"
ENV PDK_VERSION=1.2.1

# puppet agent install
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm \
    && yum upgrade -y \
    && yum update -y \
    && yum install -y epel-release \
    && yum install -y puppet-agent-"${PUPPET_AGENT_VERSION}" \

# required for the gem files
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y git-all
RUN yum install -y libffi-devel
RUN yum install -y ruby-devel
RUN yum install -y zlib-devel
RUN yum clean all

# puppet-azure requirments
RUN /opt/puppetlabs/puppet/bin/gem install retries --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure --version='~>0.7.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure_mgmt_compute --version='~>0.3.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure_mgmt_storage --version='~>0.3.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure_mgmt_resources --version='~>0.3.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure_mgmt_network --version='~>0.3.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install hocon --version='~>1.1.2' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install aws-sdk-core --no-ri --no-rdoc

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN puppet module install puppetlabs-azure --version ${PUPPET_MODULE_AZURE_VERSION}
RUN puppet module install puppetlabs-aws --version ${PUPPET_MODULE_AWS_VERSION}
RUN puppet module install puppetlabs-stdlib --version ${PUPPET_MODULE_STDLIB_VERSION}
RUN puppet module install keirans-azuremetadata --version 0.1.1

# PDK
RUN yum -y install https://puppet-pdk.s3.amazonaws.com/pdk/${PDK_VERSION}/repos/el/7/PC1/x86_64/pdk-${PDK_VERSION}-1.el7.x86_64.rpm

# puppet strings for documentation of your modules
# https://github.com/puppetlabs/puppet-strings 
RUN puppet resource package yard provider=puppet_gem
RUN puppet resource package puppet-strings provider=puppet_gem

# Install JQ
WORKDIR /usr/local/bin/
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN mv jq-linux64 jq
RUN chmod 755 /usr/local/bin/jq

ENTRYPOINT [""]

CMD ["/bin/bash"]
# CMD ["agent", "--verbose", "--onetime", "--no-daemonize", "--summarize" ]
