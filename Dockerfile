FROM alpine

RUN apk update && apk add --no-cache --update jq

COPY ./nsd /usr/local/bin/
COPY ./nscli /usr/local/bin/
COPY ./init.sh ./

# ENTRYPOINT ["./init.sh"]