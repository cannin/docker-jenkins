FROM ubuntu:16.04
MAINTAINER cannin

##### UBUNTU
# Update Ubuntu and add extra repositories
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install software-properties-common
RUN apt-get update

# Install basic commands
RUN apt-get -y install links nano wget curl git mercurial htop

# Install Java
RUN add-apt-repository -y ppa:openjdk-r/ppa

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install openjdk-8-jdk

## Install Jenkins
RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'

RUN apt-get update
RUN apt-get -y install jenkins

# Install build commands
RUN apt-get -y install unzip zip jq

# Needed for Docker-based pipelines
RUN apt-get install -y libltdl7 && rm -rf /var/lib/apt/lists/*

##### JENKINS SETUP
ENV JENKINS_UC https://updates.jenkins-ci.org
ENV JENKINS_REF /usr/share/jenkins/ref
ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_WAR /usr/share/jenkins/jenkins.war
#ENV JAVA_OPTS
#ENV JENKINS_OPTS

RUN mkdir -p $JENKINS_REF/plugins
RUN mkdir -p $JENKINS_REF/jobs
RUN chown -R jenkins $JENKINS_REF

VOLUME $JENKINS_HOME

#USER jenkins

#COPY plugins.txt /usr/share/jenkins/plugins.txt
#COPY plugins.sh /usr/local/bin/plugins.sh
#RUN chmod u+x /usr/local/bin/plugins.sh
#RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

RUN curl -L $JENKINS_UC/latest/greenballs.hpi -o $JENKINS_REF/plugins/greenballs.hpi && \
    curl -L $JENKINS_UC/latest/tap.hpi -o $JENKINS_REF/plugins/tap.hpi && \
    curl -L $JENKINS_UC/latest/ssh-credentials.hpi -o $JENKINS_REF/plugins/ssh-credentials.hpi && \
    curl -L $JENKINS_UC/latest/mercurial.hpi -o $JENKINS_REF/plugins/mercurial.hpi && \
    curl -L $JENKINS_UC/latest/maven-plugin.hpi -o $JENKINS_REF/plugins/maven-plugin.hpi && \
    curl -L $JENKINS_UC/latest/mailer.hpi -o $JENKINS_REF/plugins/mailer.hpi && \
    curl -L $JENKINS_UC/latest/git-client.hpi -o $JENKINS_REF/plugins/git-client.hpi && \
    curl -L $JENKINS_UC/latest/git.hpi -o $JENKINS_REF/plugins/git.hpi

#$JAVA $JAVA_ARGS -jar $JENKINS_WAR $JENKINS_ARGS
#ENTRYPOINT ["java", $JAVA_ARGS, "-jar", $JENKINS_WAR, $JENKINS_ARGS]

# for main web interface:
EXPOSE 8080

COPY jenkins.sh /usr/local/bin/jenkins.sh
RUN chmod u+x /usr/local/bin/jenkins.sh

CMD ["/usr/local/bin/jenkins.sh"]
