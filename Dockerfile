# -------- Stage 1: Build the JAR using Maven --------
# Use Maven image with OpenJDK 11 to build the project
# FROM maven:3.8.8-openjdk-11 AS builder
FROM maven:3-openjdk-11 AS builder

# Set working directory inside the container
WORKDIR /build

# Copy Maven descriptor and download dependencies first (improves build cache)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the full project into the container
COPY . .

# Build the Spring Boot JAR (skip tests for faster build)
RUN mvn clean package -DskipTests

# -------- Stage 2: Create lightweight image with only the JAR --------
# Use slim OpenJDK 11 for minimal runtime image
FROM openjdk:11-jdk-slim

# Set working directory
WORKDIR /app

# Copy only the JAR file from the previous build stage
COPY --from=builder /build/target/my-spring-app.jar app.jar

# Expose Spring Boot default port
EXPOSE 8080

# Run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]
