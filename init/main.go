package main

import (
	"context"
	"log"
	"os"

	"cloud.google.com/go/firestore"
)

type Coffee struct {
	ID          string
	Name        string
	Rating      int
	Description string
}

var coffees = []Coffee{
	{ID: "01", Name: "The Incident Response Roast", Rating: 5, Description: "A bold and strong roast, ready to fuel those late-night troubleshooting sessions."},
	{ID: "02", Name: "Masham Meet", Rating: 5, Description: "A cozy and comforting roast featuring warm notes of hazelnut and caramel."},
	{ID: "03", Name: "Chrome Caramel", Rating: 2, Description: "A luxuriously smooth coffee with a rich caramel richness."},
	{ID: "04", Name: "The Whitby Pixel", Rating: 5, Description: "Fly-by-the-pants flavour. Delightful brew with an incredible user experience to boot."},
	{ID: "05", Name: "Cloud Running", Rating: 5, Description: "A smooth and mellow coffee best consumed during sprints"},
	{ID: "06", Name: "London Luongo", Rating: 5, Description: "Perfect for dark and rainy days in London Gov!"},
	{ID: "07", Name: "Manchester Macchiato", Rating: 3, Description: "The best coffee for busy worker bees"},
	{ID: "08", Name: "Scarborough Search", Rating: 1, Description: "This medium roast combines smooth chocolate notes with a nutty complexity."},
	{ID: "09", Name: "The Harlow Carr Roast", Rating: 5, Description: "nspired by the beautiful gardens, this floral and delicate coffee offers hints of lavender and sweet citrus."},
	{ID: "10", Name: "The Valley Gardens Java", Rating: 4, Description: "A light and refreshing summery coffee with hints of berry and a lingering sweetness."},
	{ID: "11", Name: "SLO Brew", Rating: 5, Description: "A balanced and reliable coffee that delivers a consistent flavor profile."},
	{ID: "12", Name: "Guatemalan Huehuetenango", Rating: 3, Description: "A medium-bodied coffee with a chocolatey flavor and a sweet aftertaste."},
	{ID: "13", Name: "Hazelnut Cream", Rating: 3, Description: "A sweet and creamy coffee with a hazelnut flavor."},
	{ID: "14", Name: "Harrogate Honey Roast", Rating: 4, Description: "A sweet and mellow coffee with notes of golden honey and a smooth finish."},
	{ID: "15", Name: "Kenyan AA", Rating: 4, Description: "A full-bodied coffee with a bold flavor and a winey aftertaste."},
	{ID: "16", Name: "Latte", Rating: 2, Description: "A coffee drink made with espresso and steamed milk."},
	{ID: "17", Name: "Mocha", Rating: 2, Description: "A coffee drink made with espresso, chocolate, and steamed milk."},
	{ID: "18", Name: "DORA Roast", Rating: 5, Description: "A complex and intriguing coffee with hidden depths of flavor waiting to be explored."},
	{ID: "19", Name: "Maps Mocha", Rating: 5, Description: "A comforting classic with rich chocolate notes and a hint of warmth."},
	{ID: "20", Name: "Sumatran Mandheling", Rating: 3, Description: "A dark and earthy coffee with a smoky flavor."},
}

func main() {
	// TODO change this if deploying elsewhere
	projectID := os.Getenv("PROJECT_ID")
	if projectID == "" {
		projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")
	}
	if projectID == "" {
		projectID = os.Getenv("DEVSHELL_PROJECT_ID")
	}
	if projectID == "" {
		log.Fatalln("expected PROJECT_ID variable to be set")
	}
	// Set up a Firestore client.
	ctx := context.Background()
	client, err := firestore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create Firestore client: %v", err)
	}
	for _, c := range coffees {
		_, err = client.Collection("coffees").Doc(c.ID).Set(ctx, c)
		if err != nil {
			log.Printf("Failed to create coffee: %v", err)
		}
		log.Printf("Created coffee: %v", c)
	}
}
