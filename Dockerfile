FROM openjdk:8-jre-alpine
MAINTAINER Your Name <yourname@cisco.com>


COPY ./target/sample-spring-boot-app-0.1.0.jar /

RUN date > /build_time.txt

CMD ["java", "-jar", "/sample-spring-boot-app-0.1.0.jar"]

EXPOSE 8080

#ENTRYPOINT ["/usr/bin/java"]
