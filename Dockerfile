## docker build -t onzyone/puppet-dev

FROM centos:7

# puppet 4.x
ENV PUPPET_AGENT_VERSION="1.10.10"
ENV PUPPET_MODULE_AZURE_VERSION="1.3.1"
ENV PUPPET_MODULE_AWS_VERSION="2.1.0"
ENV PUPPET_MODULE_STDLIB_VERSION="4.23.0"
ENV PUPPET_MODULE_AZUREMETADATA_VERSION="0.1.3"
ENV PUPPET_MODULE_GOOGLE_CLOUD_VERSION="0.2.2"
ENV PDK_VERSION="1.3.2.0"

# puppet agent and pdk
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum install -y epel-release; yum upgrade -y; yum update -y
RUN yum install -y puppet-agent-"${PUPPET_AGENT_VERSION}"
RUN yum install -y pdk-"${PDK_VERSION}"

RUN rm -rf /etc/puppetlabs/puppet/hiera.yaml

# required for the gem files
#RUN yum install -y python34-devel
RUN yum install -y gcc gcc-c++ git-all libffi-devel python-devel python-pip python34 ruby-devel strace vim wget unzip zlib-devel zip && yum clean all

# Install the AWS CLI Tools
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/var/tmp/awscli-bundle.zip"
WORKDIR /var/tmp/
RUN unzip awscli-bundle.zip
WORKDIR /var/tmp/awscli-bundle/
RUN /var/tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm -rf /var/tmp/awscli-bundle.zip /var/tmp/awscli-bundle

# Install the Azure CLI and boto3 for aws python interaction
WORKDIR /var/tmp/
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN /usr/bin/python3 get-pip.py
RUN /usr/bin/pip3 install azure-cli boto3
#RUN rm -f /bin/python
#RUN ln -s /bin/python3 /bin/python

# Install google cloud sdk

RUN echo [google-cloud-sdk]  > /etc/yum.repos.d/google-cloud-sdk.repo
RUN echo name=Google Cloud SDK >> /etc/yum.repos.d/google-cloud-sdk.repo
RUN echo baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64 >> /etc/yum.repos.d/google-cloud-sdk.repo
RUN echo enabled=1 >> /etc/yum.repos.d/google-cloud-sdk.repo
RUN echo gpgcheck=1 >> /etc/yum.repos.d/google-cloud-sdk.repo
RUN echo repo_gpgcheck=1 >> /etc/yum.repos.d/google-cloud-sdk.repo
RUN echo gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg \
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg >> /etc/yum.repos.d/google-cloud-sdk.repo

RUN yum -y install google-cloud-sdk

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

# puppet modules for each of the cloud providors
RUN puppet module install puppetlabs-azure --version ${PUPPET_MODULE_AZURE_VERSION}
RUN puppet module install puppetlabs-aws --version ${PUPPET_MODULE_AWS_VERSION}
RUN puppet module install puppetlabs-stdlib --version ${PUPPET_MODULE_STDLIB_VERSION}
RUN puppet module install keirans-azuremetadata --version ${PUPPET_MODULE_AZUREMETADATA_VERSION}
RUN puppet module install google-cloud --version ${PUPPET_MODULE_GOOGLE_CLOUD_VERSION}

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
