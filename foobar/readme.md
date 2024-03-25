# Blackhole Demo

This simple web app simulates service failures by "blackholing" a certain percentage of traffic. This helps demonstrate SRE (Site Reliability Engineering) practices. By default, the app responds with an HTTP `500` error and an error message (in both web and logs) 100% of the time. You can customize the failure rate by setting the `FAIL_RATE` environment variable.  Successful responses (when not failing 100%) will return an HTTP `200` status code with a positive message.

This container was created to demonstrate SLOs (Service Level Objectives) within Cloud Run, particularly error budget burn rate and Google Cloud alerting/incident management.


## Build
To build the container, use the following `gcloud` command: 
`gcloud builds submit --tag europe-docker.pkg.dev/<location>/<name>/ui:foobar .`


## Local
To run or test locally:
```FAIL_RATE="50" go run main.go```