FROM frolvlad/alpine-oraclejdk8:slim
COPY target/spring-petclinic-1.5.1.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]