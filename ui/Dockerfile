FROM golang:1.20 AS build
WORKDIR /go/src/app
COPY *.go go.mod  ./
RUN go build -o app

FROM gcr.io/distroless/base-debian12 AS run
WORKDIR /
COPY templates /templates
COPY static /static
COPY --from=build /go/src/app/app /app
ENTRYPOINT ["/app"]