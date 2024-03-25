package main

import (
    "fmt"
    "log"
    "math/rand"
    "net/http"
    "os"
    "strings" 
    "strconv"
    "time"
	"github.com/sirupsen/logrus"
)

func init() {
    // Disable log prefixes such as the default timestamp.
    log.SetFlags(0)
}

type Entry struct {
    Severity  string `json:"severity"`
    Message   string `json:"message"`
    Component string `json:"component,omitempty"`
    Trace     string `json:"logging.googleapis.com/trace,omitempty"`
}

func blackholeHandler(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path == "/favicon.ico" {
        w.WriteHeader(http.StatusNotFound) // Or any other status code you prefer
        return
    }

	logger := logrus.New()

    // Simulate failure with a certain probability
    if rand.Intn(100) < 99 {
        // Get FAIL_RATE from environment, otherwise default to 100% fail
        failRateStr := os.Getenv("FAIL_RATE")
        failRate := 100
        if failRateStr != "" {
                var err error
                failRate, err = strconv.Atoi(failRateStr)
                if err != nil {
                        log.Printf("Invalid FAIL_RATE environment variable: %v", err)
                }
        }

        if rand.Intn(100) < failRate {
                w.WriteHeader(http.StatusInternalServerError)
                fmt.Fprintf(w, "<p style='font-size: 75px;' class='error-message'> \u2716 Espresso down, coffee not found</p>")
                logger.Error("Coffee machine exploded!")

		logger.WithFields(logrus.Fields{
			"Severity":  "WARN",
			"Message":   "YOU SHOULD NEVER SEE THIS!!! Mild panic - experimental rearchitecture of coffee related things.",
			"Component": "blackholeHandler",
			"Trace":     extractTraceID(r),
		}).Warn("Something went wrong")

        } else {
            w.WriteHeader(http.StatusOK) // 200 OK
            fmt.Fprintf(w, "<p style='font-size: 75px;' class='error-message'>Coffee is ready! Enjoy &#x2615;</p>") 
        }
        return
    }
}


func extractTraceID(r *http.Request) string {
 	projectID := os.Getenv("GCP_PROJECT") 

    traceHeader := r.Header.Get("X-Cloud-Trace-Context")
    traceParts := strings.Split(traceHeader, "/")
    if len(traceParts) > 0 && len(traceParts[0]) > 0 {
        return fmt.Sprintf("projects/%s/traces/%s", projectID, traceParts[0])
    }
    return ""
}

func main() {
    rand.Seed(time.Now().UnixNano()) // Seed the random number generator 
    http.HandleFunc("/", blackholeHandler)
    fmt.Println("Blackhole server listening on port 8080")
    err := http.ListenAndServe(":8080", nil)
    if err != nil {
        fmt.Fprintln(os.Stderr, "Error starting server:", err)
    }
}