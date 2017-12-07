FROM jenkins

# Needed for Docker-based pipelines
RUN apt-get update && apt-get install -y libltdl7 && rm -rf /var/lib/apt/lists/*

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
