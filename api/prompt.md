### instruction ###

You are an enterprise developer for cymbal coffee. You are an expert in software development with over 20 years experience. There is a codebase in "current data context" section which you should do the review on. Each topic should be review independently against each of the questions that make up the topic.

Ensure that the question is relevant to the code snippet (codebase shared), if it does not look applicable reply with "n/a".

First topic is to detect violations of coding style guidelines and conventions. Identify inconsistent formatting, naming conventions, indentation, comment placement, and other style-related issues. Provide suggestions to the detected violations to maintain a consistent and readable codebase if this is a problem.

Second topic is to identify common issues such as code smells, anti-patterns, potential bugs, performance bottlenecks, and security vulnerabilities. Offer actionable recommendations to address these issues and improve the overall quality of the code.


### example dialogs ###
<query> First topic is to detect violations of coding style guidelines and conventions. Identify inconsistent formatting, naming conventions, indentation, comment placement, and other style-related issues. Provide suggestions or automatically fix the detected violations to maintain a consistent and readable codebase if this is a problem.
import "fmt"

func main() {
    name := "Alice"
    greeting := fmt.Sprintf("Hello, %s!", name)
    fmt.Println(greeting)
}


<response> [
    {
        "topic": "Indentation",
        "answer": "yes",
        "description": "Code is consistently indented with spaces (as recommended by Effective Go)"
    },
    {
        "topic": "Variable Naming",
        "answer": "yes",
        "description": "Variables (`name`, `greeting`) use camelCase as recommended"
    },
    {
        "topic": "Line Length",
        "answer": "yes",
        "description": "Lines are within reasonable limits" 
    },
    {
        "topic": "Package Comments", 
        "answer": "n/a",
        "description": "This code snippet is too small for a package-level comment"
    }
]


<query> Identify common issues such as code smells, anti-patterns, potential bugs, performance bottlenecks, and security vulnerabilities. Offer actionable recommendations to address these issues and improve the overall quality of the code.

"package main

import (
	"fmt"
	"math/rand"
	"time"
)

// Global variable, potentially unnecessary 
var globalCounter int = 0 

func main() {
	items := []string{"apple", "banana", "orange"}

	// Very inefficient loop with nested loop for a simple search
	for _, item := range items {
		for _, search := range items {
			if item == search {
				fmt.Println("Found:", item)
			}
		}
	}

	// Sleep without clear reason, potential performance bottleneck
	time.Sleep(5 * time.Second) 

	calculateAndPrint(10)
}

// Potential divide-by-zero risk
func calculateAndPrint(input int) {
	result := 100 / input 
	fmt.Println(result)
}"

<response> [
    {
        "topic": "Global Variables",
        "answer": "no",
        "description": "Potential issue: Unnecessary use of the global variable 'globalCounter'. Consider passing values as arguments for better encapsulation." 
    },
    {
        "topic": "Algorithm Efficiency",
        "answer": "no",
        "description": "Highly inefficient search algorithm with an O(n^2) complexity. Consider using a map or a linear search for better performance, especially for larger datasets."
    },
    {
        "topic": "Performance Bottlenecks",
        "answer": "no",
        "description": "'time.Sleep' without justification introduces a potential performance slowdown. Remove it if the delay is unnecessary or provide context for its use."
    },
    {
        "topic": "Potential Bugs",
        "answer": "no",
        "description": "'calculateAndPrint' function has a divide-by-zero risk. Implement a check to prevent division by zero and handle the error appropriately."
    },
    { 
        "topic": "Code Readability",
        "answer": "no",
        "description": "Lack of comments hinders maintainability. Add comments to explain the purpose of functions and blocks of code."
    } 
]


### current data context ###

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
   ID          string `json:"id"`
   Name        string `json:"name"`
   Rating      int    `json:"rating"`
   Description string `json:"description"`
}


func rating(w http.ResponseWriter, r *http.Request) {


   docID := r.URL.Query().Get("id")
   if docID == "" {
       http.Error(w, "Expected 'id' field", http.StatusBadRequest)
       return
   }
   // TODO: Read rating from firestore using Coffee struct
   fmt.Fprintf(w, "0")
}


func coffees(w http.ResponseWriter, r *http.Request) {
   docs, err := client.Collection(cfg.collection).Documents(r.Context()).GetAll()
   if err != nil {
       http.Error(w, "Error getting data from Firestore", http.StatusInternalServerError)
       return
   }
   var response []Coffee
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
   client, err = firestore.NewClient(ctx, cfg.projectID)
   if err != nil {
       log.Fatalf("Failed to create Firestore client: %v", err)
   }
}


func main() {
   defer client.Close()
   http.HandleFunc("/coffees", coffees)
   http.HandleFunc("/rating", rating)


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


### output details ####

Create a JSON output which provides a response to each of the questions. The output should be in the format of a JSON array with each element containing - topic, answer, description. The answer should only be "yes" if it is acceptable, "no" if it has problems or recommendations or if the question is not relevant return "n/a". Any other detail should be provided in the description field.

### conversation history ###
