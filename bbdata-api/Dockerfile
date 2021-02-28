FROM openjdk:11

RUN useradd --create-home -s /bin/bash bbuser
WORKDIR /home/bbuser
USER bbuser

ENV BB_NO_KAFKA=true

VOLUME /home/bbuser/config
EXPOSE 8080 8111

RUN wget https://github.com/big-building-data/bbdata-api/releases/download/v2.0.0-alpha/bbdata-api-2.0.0-alpha.jar \
    && mv bbdata-api-2.0.0-alpha.jar /home/bbuser/bbdata-api.jar \
    && chmod +x /home/bbuser/bbdata-api.jar

COPY application.properties /home/bbuser/config/application.properties

ENTRYPOINT /home/bbuser/bbdata-api.jar --spring.config.additional-location=/home/bbuser/config/application.properties