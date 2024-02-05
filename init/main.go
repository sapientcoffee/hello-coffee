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
	{ID: "01", Name: "Untitled Coffee", Rating: 5, Description: "A coffee that desperately needs a brand. Coming soon for 2024 with three priority flavours."},
	{ID: "02", Name: "Project Bridge Beans", Rating: 5, Description: "A cross-collaboration to bring the best of beans and AI to your mouth"},
	{ID: "03", Name: "Crispcam Coldbrew", Rating: 2, Description: "A somewhat legacy blend, still talked about but rarely consumed."},
	{ID: "04", Name: "Drone Derby Drip", Rating: 5, Description: "Fly-by-the-pants flavour. Delightful brew with an incredible user experience to boot!"},
	{ID: "05", Name: "Cloud Running", Rating: 5, Description: "A smooth and mellow coffee best consumed during sprints"},
	{ID: "06", Name: "London Luongo", Rating: 5, Description: "Perfect for dark and rainy days in London Gov!"},
	{ID: "07", Name: "Manchester Macchiato", Rating: 3, Description: "The best coffee for busy worker bees"},
	{ID: "08", Name: "Party Popper Pot", Rating: 1, Description: "A smooth and balanced coffee with a nutty flavor, but without the caffeine."},
	{ID: "09", Name: "Decaf Drone Derby Drip", Rating: 5, Description: "Fly-by-the-pants flavour. Delightful brew with an incredible user experience to boot!"},
	{ID: "10", Name: "Espresso", Rating: 4, Description: "A strong and concentrated coffee drink with a rich flavor."},
	{ID: "11", Name: "Ethiopian Yirgacheffe", Rating: 5, Description: "A bright and citrusy coffee with a complex flavor profile."},
	{ID: "12", Name: "Guatemalan Huehuetenango", Rating: 3, Description: "A medium-bodied coffee with a chocolatey flavor and a sweet aftertaste."},
	{ID: "13", Name: "Hazelnut Cream", Rating: 3, Description: "A sweet and creamy coffee with a hazelnut flavor."},
	{ID: "14", Name: "Iced Coffee", Rating: 4, Description: "A refreshing and delicious coffee drink that is perfect for a hot day."},
	{ID: "15", Name: "Kenyan AA", Rating: 4, Description: "A full-bodied coffee with a bold flavor and a winey aftertaste."},
	{ID: "16", Name: "Latte", Rating: 2, Description: "A coffee drink made with espresso and steamed milk."},
	{ID: "17", Name: "Mocha", Rating: 2, Description: "A coffee drink made with espresso, chocolate, and steamed milk."},
	{ID: "18", Name: "Nitro Coffee", Rating: 5, Description: "A creamy and delicious coffee drink with a foamy head."},
	{ID: "19", Name: "Project Bridge Beans", Rating: 5, Description: "A cross-collaboration to bring the best of beans and AI to your mouth"},
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
