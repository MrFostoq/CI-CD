# Use a base image with Java 17
FROM eclipse-temurin:17-jdk

# Set working directory
WORKDIR /app

# Copy the built jar file into the image
COPY target/*.jar app.jar

# Run the jar file
ENTRYPOINT ["java", "-jar", "app.jar"]
