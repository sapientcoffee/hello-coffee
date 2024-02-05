FROM golang:1.20 AS build
WORKDIR /go/src/app
COPY *.go go.mod go.sum ./
RUN go build -o app
