gcr.io/distroless/nodejs-debian11


FROM taobeier/alpine-distroless

FROM alpine:3
RUN apk update && apk add curl ca-certificates shc

COPY ./get-shc .
