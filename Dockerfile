FROM alpine:latest

RUN apk add --no-cache curl wget jq

CMD ["/bin/sh"]