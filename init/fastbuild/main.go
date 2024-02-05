package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"cloud.google.com/go/firestore"
)

var client *firestore.Client
var cfg config

type Coffee struct {
	Name        string `json:"name"`
	Rating      int    `json:"rating"`
	Description string `json:"description"`
}

func rating(w http.ResponseWriter, r *http.Request) {
	// Get the coffee document ID
	docID := r.URL.Query().Get("name")
	if docID == "" {
		http.Error(w, "Expected 'name' field", http.StatusBadRequest)
		return
	}
	// TODO: Read rating from firestore using Coffee struct
	fmt.Fprintf(w, "0")
}

func coffees(w http.ResponseWriter, r *http.Request) {
	// Get the coffee document ID
	docs, err := client.Collection(cfg.collection).Documents(r.Context()).GetAll()
	if err != nil {
		http.Error(w, "Error getting data from Firestore", http.StatusInternalServerError)
		return
	}
	var response []Coffee
	// Convert
	for _, doc := range docs {
		var c Coffee
		doc.DataTo(&c)
		response = append(response, c)
	}
	json.NewEncoder(w).Encode(response)

}

func init() {
	ctx := context.Background()
	initConfig(ctx)
	var err error
	// Set up a Firestore client.
	client, err = firestore.NewClient(ctx, cfg.projectID)
	if err != nil {
		log.Fatalf("Failed to create Firestore client: %v", err)
	}
}

func main() {
	defer client.Close()
	// Create a route to handle requests to the root URL.
	http.HandleFunc("/coffees", coffees)
	http.HandleFunc("/rating", rating)

	// Start the web server.
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%v", cfg.port), nil))
}

type config struct {
	port       string
	projectID  string
	collection string
}

const (
	defaultPort       = "8080"
	defaultCollection = "coffees"
)

func initConfig(ctx context.Context) {
	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}
	cfg.port = port

	collection := os.Getenv("COLLECTION")
	if collection == "" {
		collection = defaultCollection
	}
	cfg.collection = collection

	// Obtain Project ID from metadata server unless specified
	projectID := os.Getenv("PROJECT_ID")
	if projectID == "" {
		projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	}
	if projectID == "" {
		projectID = os.Getenv("DEVSHELL_PROJECT_ID")
	}
	if projectID == "" {
		log.Println("Fetching Project ID from metadata server")
		metadataURL := "http://metadata.google.internal/computeMetadata/v1/project/project-id"
		// Send a GET request to the metadata server
		// Do this to make it super-simple for CEs to deploy
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, metadataURL, nil)
		if err != nil {
			log.Printf("Warning - could not retrieve project ID from metadata server")
			log.Fatalln(err)
		}
		req.Header.Set("Metadata-Flavor", "Google")
		client := http.Client{}
		res, err := client.Do(req)
		if err != nil {
			log.Printf("Warning - could not retrieve project ID from metadata server")
			log.Fatalln(err)
		}
		b, err := io.ReadAll(res.Body)
		if err != nil {
			log.Printf("Warning - could not retrieve project ID from metadata server")
			log.Fatalln(err)
		}
		projectID = string(b)
	}
	if projectID == "" {
		log.Fatalf("Expected PROJECT_ID environment variable to be set")
	}
	cfg.projectID = projectID

	log.Printf("Running in project: %v\n", projectID)

}
