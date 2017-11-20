## docker build -t onzyone/puppet-dev

FROM centos:7

# puppet 4.x
ENV PUPPET_AGENT_VERSION="1.10.9"
ENV PUPPET_MODULE_AZURE_VERSION="1.2.0"
ENV PUPPET_MODULE_AWS_VERSION="2.0.0"
ENV PUPPET_MODULE_STDLIB_VERSION="4.20.0"
ENV PDK_VERSION="1.2.1.0"

# puppet agent and pdk
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum install -y epel-release
RUN yum upgrade -y
RUN yum update -y
RUN yum install -y puppet-agent-"${PUPPET_AGENT_VERSION}"
RUN yum install -y  https://puppet-pdk.s3.amazonaws.com/pdk/${PDK_VERSION}/repos/el/7/PC1/x86_64/pdk-${PDK_VERSION}-1.el7.x86_64.rpm

RUN rm -rf /etc/puppetlabs/puppet/hiera.yaml

# required for the gem files
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y git-all
RUN yum install -y libffi-devel
RUN yum install -y python-devel 
RUN yum install -y python-pip 
RUN yum install -y python34 
#RUN yum install -y python34-devel
RUN yum install -y ruby-devel
RUN yum install -y strace
RUN yum install -y vim
RUN yum install -y wget
RUN yum install -y unzip
RUN yum install -y zlib-devel
RUN yum install -y zip
RUN yum clean all

# Install the AWS CLI Tools
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/var/tmp/awscli-bundle.zip"
WORKDIR /var/tmp/
RUN unzip awscli-bundle.zip
WORKDIR /var/tmp/awscli-bundle/
RUN /var/tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm -f /var/tmp/awscli-bundle.zip
RUN rm -rf /var/tmp/awscli-bundle

# Install the Azure CLI
WORKDIR /var/tmp/
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN /usr/bin/python3 get-pip.py
RUN /usr/bin/pip3 install azure-cli
#RUN rm -f /bin/python
#RUN ln -s /bin/python3 /bin/python

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
