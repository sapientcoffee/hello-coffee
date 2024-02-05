package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"strconv"
)

var cfg config

const (
	defaultPort = "8080"
	defaultApi  = "http://localhost:8080"
)

type config struct {
	port string
	api  string
}

type Coffee struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Rating      int    `json:"rating"`
	Description string `json:"description"`
}

type Page struct {
	Coffees   []Coffee
	Title     string
	RatingMap map[string]int
	Stars     [5]int
}

func home(w http.ResponseWriter, r *http.Request) {
	// Make rest call to API service
	q, err := http.Get(fmt.Sprintf("%v/coffees", cfg.api))
	if err != nil {
		http.Error(w, "Error querying upstream", http.StatusInternalServerError)
		log.Printf("Error: %v", err)
		return
	}
	rd, err := io.ReadAll(q.Body)
	if err != nil {
		http.Error(w, "Error parsing response", http.StatusInternalServerError)
		log.Printf("Error: %v", err)
		return
	}
	p := Page{
		Title:     "Cymbal Coffee",
		RatingMap: make(map[string]int),
		Stars:     [5]int{1, 2, 3, 4, 5},
	}

	// Unmarshall json into an array of coffee
	json.Unmarshal(rd, &p.Coffees)
	// Iterate through and get ratings (this is really inefficient and demo-y)
	for _, c := range p.Coffees {
		qu, err := http.Get(fmt.Sprintf("%v/rating?id=%v", cfg.api, url.QueryEscape(c.ID)))
		if err != nil {
			http.Error(w, "Error querying upstream", http.StatusInternalServerError)
			log.Printf("Error: %v", err)
			return
		}
		rating, err := io.ReadAll(qu.Body)
		if err != nil {
			http.Error(w, "Error parsing response", http.StatusInternalServerError)
			log.Printf("Error: %v", err)
			return
		}
		i, err := strconv.Atoi(string(rating))
		if err != nil {
			http.Error(w, "Error parsing response", http.StatusInternalServerError)
			log.Printf("Error: %v", err)
			return
		}
		p.RatingMap[c.Name] = int(i)
	}
	// Compile and run the template
	t := template.Must(template.New("index.html").ParseFiles("templates/index.html"))
	err = t.Execute(w, p)
	if err != nil {
		http.Error(w, "Error rendering template", http.StatusInternalServerError)
		log.Printf("Error: %v", err)
		return
	}

	//fmt.Printf("%+v", c)

}

func init() {
	port := os.Getenv("PORT")
	if port == "" {
		port = defaultPort
	}
	cfg.port = port

	api := os.Getenv("API_SERVICE")
	if api == "" {
		api = defaultApi
	}
	cfg.api = api
}

func main() {
	// Create a route to handle requests to the root URL.
	http.HandleFunc("/", home)
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))

	// Start the web server.
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%v", cfg.port), nil))
}
