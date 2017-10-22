# jenkins-dind-nodejs

[![Travis Status][travis-image]][travis-url]
[![Docker Status][docker-image]][docker-url]

## Usage

### Pull image

```bash
docker pull leelow29/jenkins-dind-nodejs
```

### (Optional) Create a directory for the jenkins volume

```bash
mkdir /srv/jenkins
chmod 0666 /srv/jenkins
```

### Create and run a container

```bash
docker run --name jenkins --privileged -d -p 127.0.0.1:8080:8080 -v /srv/jenkins:/var/jenkins_home jenkins-dind-nodejs:latest
```

Note: the flag `--priviledged` is necessary to be able to use `docker` from the container.

In this example, the jenkins web interface is available at http://127.0.0.1:8080. If you want to login as admin, you can get the initial admin password typing the following command:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

## Build

```bash
git clone https://github.com/Leelow/jenkins-dind-nodejs.git
cd jenkins-dind-nodejs
docker build -t jenkins-dind-nodejs .
```

## License

[MIT](LICENSE)

[travis-image]: https://travis-ci.org/Leelow/jenkins-dind-nodejs.svg?branch=master
[travis-url]: https://travis-ci.org/Leelow/jenkins-dind-nodejs
[docker-image]: https://img.shields.io/docker/build/leelow29/jenkins-dind-nodejs.svg
[docker-url]: https://hub.docker.com/r/leelow29/jenkins-dind-nodejs/
