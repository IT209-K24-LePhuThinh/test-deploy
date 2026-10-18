FROM gradle:8.14-jdk21-alpine AS build
WORKDIR /workspace

COPY build.gradle settings.gradle ./
RUN gradle dependencies --no-daemon -q

COPY src ./src
RUN gradle bootJar -x test --no-daemon -q

FROM eclipse-temurin:21-jre-alpine AS runtime
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

WORKDIR /app

RUN addgroup -S lethinh && adduser -S lethinh -G lethinh

COPY --from=build --chown=lethinh:lethinh /workspace/build/libs/app.jar /app/app.jar
USER lethinh

EXPOSE 8086

ENTRYPOINT ["java", "-jar", "/app/app.jar"]