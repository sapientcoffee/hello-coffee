# Build Stage
FROM golang:1.20 AS build 
WORKDIR /go/src/app 
COPY *.go go.mod ./  
RUN go get -d -v ./...  # Fetch all dependencies efficiently

# COPY *.go ./
RUN go build -o app

# Final Stage
FROM gcr.io/distroless/base-debian12 AS run 
WORKDIR /
COPY --from=build /go/src/app/app /app
ENTRYPOINT ["/app"]
