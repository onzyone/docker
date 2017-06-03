# 
# Create a docker image suitable for day to day use when on client
# sites rather than pollute the OSX Base OS on my laptop.
#
FROM centos:7
MAINTAINER Keiran Sweet "Keiran@gmail.com"
RUN yum -y update
RUN yum -y install which git vim mlocate curl sudo unzip file python-devel
RUN useradd -m -u 501 keiran
RUN chown keiran:keiran /home/keiran/

# Install RVM and a copy of Ruby 2.3
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN usermod -G rvm keiran
RUN usermod -G rvm root
RUN su - root -c "rvm install 2.3"

# Install the AWS CLI Tools
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/var/tmp/awscli-bundle.zip"
WORKDIR /var/tmp/
RUN unzip awscli-bundle.zip
WORKDIR /var/tmp/awscli-bundle/
RUN /var/tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm -f /var/tmp/awscli-bundle.zip
RUN rm -rf /var/tmp/awscli-bundle

# Install Puppet Enterprise
RUN yum --nogpgcheck  install -y https://pm.puppetlabs.com/puppet-agent/2016.5.1/1.8.2/repos/el/6/PC1/x86_64/puppet-agent-1.8.2-1.el6.x86_64.rpm

WORKDIR /

CMD ["/bin/bash"]


