## docker build -t onzyone/puppet-devrhel7 .

FROM richxsl/rhel7 

# puppet 4.x
ENV PUPPET_AGENT_VERSION="1.10.9"
ENV PDK_VERSION="1.2.1.0"

# puppet agent install
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
# RUN yum install -y epel-release
RUN yum upgrade -y
RUN yum update -y
RUN yum install -y puppet-agent-"${PUPPET_AGENT_VERSION}"

RUN rm -rf /etc/puppetlabs/puppet/hiera.yaml

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

# puppet strings for documentation of your modules
# https://github.com/puppetlabs/puppet-strings 
RUN puppet resource package yard provider=puppet_gem
RUN puppet resource package puppet-strings provider=puppet_gem

ENTRYPOINT [""]

CMD ["/bin/bash"]
# CMD ["agent", "--verbose", "--onetime", "--no-daemonize", "--summarize" ]
