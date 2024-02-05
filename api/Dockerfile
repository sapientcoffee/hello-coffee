FROM golang:1.20 AS build
WORKDIR /go/src/app
COPY *.go go.mod go.sum ./
RUN go build -o app

FROM gcr.io/distroless/base-debian12 AS run
WORKDIR /
COPY --from=build /go/src/app/app /app
ENTRYPOINT ["/app"]