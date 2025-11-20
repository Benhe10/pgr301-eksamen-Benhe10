# Runtime-only Dockerfile: bruker ferdigbygget jar fra target/
FROM eclipse-temurin:17-jre
WORKDIR /app

# Kopier ferdig jar som er bygget lokalt (mvn package)
# Maven bygger jar i sentiment-docker/target/*.jar
COPY target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java","-jar","/app/app.jar"]
