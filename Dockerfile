FROM ubuntu:14.04.3
MAINTAINER cannin

##### UBUNTU
# Update Ubuntu and add extra repositories
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install software-properties-common
RUN apt-add-repository -y ppa:marutter/rrutter
RUN apt-get update

# Install basic commands
RUN apt-get -y install links nano wget curl git mercurial pandoc pandoc-citeproc

RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'

RUN apt-get update
RUN apt-get -y install jenkins

# Install build commands
RUN apt-get -y install unzip zip make gcc gfortran

# Install libraries
RUN apt-get -y install libpng12-dev libjpeg-dev libxml2-dev libcurl4-gnutls-dev libcairo2-dev libxt-dev libx11-dev

# Install latex
RUN apt-get -y install texlive-base

# Necessary for getting the latest R version
RUN apt-get -y install r-base r-base-dev

# Install software needed for common R libraries
# For RCurl
RUN apt-get -y install libcurl4-openssl-dev
# For rJava
RUN apt-get -y install libpcre++-dev
RUN apt-get -y install openjdk-7-jdk
# For XML
RUN apt-get -y install libxml2-dev

##### R: COMMON PACKAGES
# To let R find Java
RUN R CMD javareconf

# Install common R packages
RUN R -e "install.packages(c('devtools', 'gplots', 'httr', 'igraph', 'knitr', 'methods', 'plyr', 'RColorBrewer', 'rJava', 'rjson', 'R.methodsS3', 'R.oo', 'sqldf', 'stringr', 'testthat', 'XML'), repos='http://cran.rstudio.com/')"

RUN R -e 'setRepositories(ind=1:6); \
  options(repos="http://cran.rstudio.com/"); \
  if(!require(devtools)) { install.packages("devtools") }; \
  library(devtools); \
  install_github("ramnathv/rCharts")'

# Install Bioconductor
RUN R -e "source('http://bioconductor.org/biocLite.R'); biocLite(c('Biobase', 'BiocCheck', 'BiocGenerics', 'BiocStyle'))"

# Install shiny related packages
RUN R -e "install.packages(c('rmarkdown', 'shiny'), repos='http://cran.rstudio.com/')"

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
