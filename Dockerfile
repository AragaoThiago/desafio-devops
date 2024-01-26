FROM openjdk:21-jdk-slim-buster

COPY . /app

WORKDIR /app

RUN chmod +x ./gradlew

EXPOSE 8080

CMD ["./gradlew", "bootRun"]
