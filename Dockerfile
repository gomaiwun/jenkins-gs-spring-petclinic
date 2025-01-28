# Use OpenJDK 17 as the base image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file into the container
COPY target/spring-petclinic-3.1.0-SNAPSHOT.jar app.jar

# Specify the port that the application listens on
EXPOSE 9000

# Command to run the application
ENTRYPOINT ["java", "-Dserver.port=9000", "-jar", "app.jar"]