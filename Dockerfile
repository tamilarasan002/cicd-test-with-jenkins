FROM registry.access.redhat.com/ubi8/ubi

# Install necessary packages
RUN yum -y install java-11-openjdk-headless tomcat && \
    yum clean all

# Set environment variables for Tomcat
ENV CATALINA_HOME /usr/share/tomcat
ENV CATALINA_BASE /usr/share/tomcat

# Copy the WAR file to the Tomcat webapps directory
COPY target/hello-world-app-1.0-SNAPSHOT.war $CATALINA_HOME/webapps/

# Expose port 8080 for Tomcat
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
