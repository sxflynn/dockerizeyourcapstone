# Use a Debian based image with Java 11
FROM openjdk:11-slim

# Set the working directory inside the Docker image
WORKDIR /app

# Install Maven
RUN apt-get update && \
    apt-get install -y maven

# Copy the entire project directory (including application.properties)
COPY . .

# Use sed to replace the database URL in the application.properties file
RUN sed -i 's|jdbc:postgresql://localhost:5432/final_capstone|jdbc:postgresql://${DB_HOST:db}:${DB_PORT:5432}/final_capstone|' src/main/resources/application.properties

# Download the project dependencies
RUN mvn dependency:go-offline

# Expose the port the app runs on
EXPOSE 9000

# Start the application using Maven
CMD ["mvn", "spring-boot:run"]