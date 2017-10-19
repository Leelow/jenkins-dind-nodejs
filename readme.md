docker build -t jenkins-dind-nodejs .
docker run --name jenkins --privileged -d -p 8081:8080 -v /srv/jenkins:/var/jenkins_home jenkins-dind-nodejs:latest
docker logs -f jenkins
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword