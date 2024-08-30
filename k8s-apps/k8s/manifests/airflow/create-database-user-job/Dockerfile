FROM alpine:latest

RUN apk add --no-cache bash postgresql-client

COPY ./create-user.sh /usr/local/bin/create-user.sh

RUN chmod +x /usr/local/bin/create-user.sh

ENTRYPOINT ["bash", "/usr/local/bin/create-user.sh"]
