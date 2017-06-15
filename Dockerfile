# 
# Create a docker image suitable for day to day use when on client
# sites rather than pollute the OSX Base OS on my laptop.
# Yes this is pretty heavy for a container....
#
FROM centos:7

ENV PUPPET_AGENT_VERSION="1.10.1"
ENV PUPPET_MODULE_AZURE_VERSION="1.1.1"
ENV PUPPET_MODULE_AWS_VERSION="2.0.0"
ENV PUPPET_MODULE_STDLIB_VERSION="4.17.0"


MAINTAINER Jason Chinsen "onzyone@gmail.com"
RUN yum -y update
RUN yum -y install epel-release
# base tools
RUN yum -y install which git vim mlocate curl sudo unzip file python-devel python-pip python34 python34-devel wget bind-utils
# required for azure client
RUN yum -y install zlib-devel gcc gcc-c++ ruby-devel git-all libffi-devel python-devel openssl-devel
# for puppet agent install
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum clean all
RUN useradd -m -u 501 jason
RUN chown jason:jason /home/jason/
RUN echo '%wheel    ALL=(ALL)    NOPASSWD:ALL' > /etc/sudoers.d/wheel
RUN chmod 0440 /etc/sudoers.d/wheel

# Install RVM and a copy of Ruby 2.3
#RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
#RUN curl -sSL https://get.rvm.io | bash -s stable
#RUN usermod -G rvm,wheel jason
#RUN usermod -G rvm root
#RUN su - root -c "rvm install 2.3"

# Install the AWS CLI Tools
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/var/tmp/awscli-bundle.zip"
WORKDIR /var/tmp/
RUN unzip awscli-bundle.zip
WORKDIR /var/tmp/awscli-bundle/
RUN /var/tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm -f /var/tmp/awscli-bundle.zip
RUN rm -rf /var/tmp/awscli-bundle

# Install Powershell
# RUN yum -y install https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.2/powershell-6.0.0_beta.2-1.el7.x86_64.rpm

# Install Puppet Enterprise
RUN yum -y install puppet-agent-"$PUPPET_AGENT_VERSION"
ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

# Install gems for Azure module
RUN /opt/puppetlabs/puppet/bin/gem install retries --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure --version='~>0.7.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure_mgmt_compute --version='~>0.3.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure_mgmt_storage --version='~>0.3.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure_mgmt_resources --version='~>0.3.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install azure_mgmt_network --version='~>0.3.0' --no-ri --no-rdoc
RUN /opt/puppetlabs/puppet/bin/gem install hocon --version='~>1.1.2' --no-ri --no-rdoc

# Install gems for aws
RUN /opt/puppetlabs/puppet/bin/gem install aws-sdk-core --no-ri --no-rdoc

# Install the Azure CLI
WORKDIR /var/tmp/
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN /usr/bin/python3 get-pip.py
RUN /usr/bin/pip3 install azure-cli
RUN rm -f /bin/python
RUN ln -s /bin/python3 /bin/python

# AWS python module
RUN /usr/bin/pip3 install boto3==1.3.0

# Install JQ
WORKDIR /usr/local/bin/
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 
RUN mv jq-linux64 jq
RUN chmod 755 /usr/local/bin/jq

# install puppet modules
RUN puppet module install puppetlabs-azure --version ${PUPPET_MODULE_AZURE_VERSION}
RUN puppet module install puppetlabs-stdlib --version ${PUPPET_MODULE_STDLIB_VERSION}
RUN puppet module install puppetlabs-aws --version ${PUPPET_MODULE_AWS_VERSION}


WORKDIR /

CMD ["/bin/bash"]


