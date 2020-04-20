FROM alpine

RUN apk update && apk add --no-cache --update jq

COPY ./bin/nsd /usr/local/bin/
COPY ./bin/nscli /usr/local/bin/
COPY ./init.sh ./

# ENTRYPOINT ["./init.sh"]