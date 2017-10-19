FROM openjdk:8-jdk

# Jenkins settings
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_UC https://updates.jenkins.io

# Docker settings
ENV DOCKER_COMPOSE_VERSION 1.7.1

# Docker prerequisites
RUN apt-get update
RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
	python-setuptools

# Install syslog-stdout
RUN easy_install syslog-stdout supervisor-stdout

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Install Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Install the wrapper script from https://raw.githubusercontent.com/docker/docker/master/hack/dind.
ADD ./files/dind /usr/local/bin/dind
RUN chmod +x /usr/local/bin/dind
ADD ./files/wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Install Jenkins
RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update && apt-get install -y zip supervisor jenkins && rm -rf /var/lib/apt/lists/*
RUN usermod -a -G docker jenkins
VOLUME /var/jenkins_home

# Get plugins.sh tool from official Jenkins repo, this allows plugin installation
ADD ./files/plugins.sh /usr/local/bin/plugins.sh
RUN chmod +x /usr/local/bin/plugins.sh

ADD ./files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install python tools
RUN easy_install pip
COPY ./files/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Copy files onto the filesystem
COPY ./files/docker /
RUN chmod +x /docker-entrypoint /usr/local/bin/*

# Install Node.js v8.x and build tools
RUN apt-get update 
RUN apt-get install -y sudo
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash
RUN sudo apt-get install -y nodejs
RUN sudo apt-get install -y build-essential

# Expose Jenkins port
EXPOSE 8080

# Set the entrypoint
ENTRYPOINT ["/docker-entrypoint"]

CMD ["/usr/bin/supervisord"]