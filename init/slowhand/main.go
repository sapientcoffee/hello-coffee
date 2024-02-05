package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	time.Sleep(1 * time.Second)

	// Create a route to handle requests to the root URL.
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// TODO: Read rating from firestore using Coffee struct
		fmt.Fprintf(w, "Hello World")
	})

	// Start the web server.
	log.Fatal(http.ListenAndServe(":8080", nil))
}
