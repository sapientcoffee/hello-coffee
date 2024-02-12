import contextlib
import json
import logging
import os
from typing import List

from google.cloud import firestore

client = None
cfg = None

class Coffee:
    def __init__(self, id: str, name: str, rating: int, description: str):
        self.id = id
        self.name = name
        self.rating = rating
        self.description = description


def rating(request: http.Request) -> http.Response:
    # Get the coffee document ID
    doc_id = request.query_params.get("id")
    if not doc_id:
        return http.Response(status=http.StatusBadRequest, text="Expected 'id' field")

    # TODO: Read rating from firestore using Coffee struct
    return http.Response(status=http.StatusOK, text="0")


def coffees(request: http.Request) -> http.Response:
    # Get the coffee document ID
    docs, err = client.collection(cfg.collection).get(contextlib.contextmanager(request)).all()
    if err:
        return http.Response(status=http.StatusInternalServerError, text="Error getting data from Firestore")

    response: List[Coffee] = []
    # Convert
    for doc in docs:
        c = Coffee(**doc.to_dict())
        response.append(c)

    return http.Response(status=http.StatusOK, content_type="application/json", text=json.dumps(response))


def init():
    ctx = contextlib.contextmanager(context.Background())
    init_config(ctx)

    global client
    client = firestore.Client(ctx, project=cfg.project_id)
    logging.info("Firestore client created")


def main():
    global client
    client.close()

    http.HandleFunc("/coffees", coffees)
    http.HandleFunc("/rating", rating)

    logging.info("Starting web server on port %s", cfg.port)
    http.listen_and_serve(f":{cfg.port}", None)


class config:
    port: str
    project_id: str
    collection: str

    def __init__(self, port: str, project_id: str, collection: str):
        self.port = port
        self.project_id = project_id
        self.collection = collection


default_port = "8080"
default_collection = "coffees"


def init_config(ctx: contextlib.ContextManager):
    global cfg
    cfg = config(
        port=os.getenv("PORT", default_port),
        project_id=os.getenv("PROJECT_ID", os.getenv("GOOGLE_CLOUD_PROJECT", os.getenv("DEVSHELL_PROJECT_ID"))),
        collection=os.getenv("COLLECTION", default_collection),
    )

    logging.info("Config initialized")


if __name__ == "__main__":
    init()
    main()
