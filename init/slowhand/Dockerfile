FROM europe-west1-docker.pkg.dev/butter-robot-demo/butter-robot-demo/fastbuild:latest AS build
WORKDIR /go/src/app
COPY *.go go.mod ./
RUN go build -o app

FROM gcr.io/distroless/base-debian12 AS run
WORKDIR /
COPY --from=build /go/src/app/app /app
ENTRYPOINT ["/app"]