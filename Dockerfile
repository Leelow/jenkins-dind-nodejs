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

# Install Puppeteer dependencies https://github.com/GoogleChrome/puppeteer/issues/290#issuecomment-322921352
RUN apt-get update && \
apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

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

# Install Node.js v8.x and build tools (including npm)
RUN apt-get update 
RUN apt-get install -y sudo
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash
RUN sudo apt-get install -y nodejs
RUN sudo apt-get install -y build-essential

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get update && sudo apt-get install yarn

# Expose Jenkins port
EXPOSE 8080

# Set the entrypoint
ENTRYPOINT ["/docker-entrypoint"]

CMD ["/usr/bin/supervisord"]
