# Coffee Time

The simple app has been created to help demonstrate various aspects of application development and Google Cloud. Its fairly basic by design and of course coffee themed!

Thing are broken down into the "inner" and "outer" loops.

![inner and outer loop sketch](./static/inner-outter-loop.png)

The following are mainly notes/prompts for me personally (I have a terrible memory at times, especially when presenting its easy to forget things), at some time I will make them more generic and parametrise various commands.

The inner loop comprises developer tasks such as coding, testing, and pushing to version control while the outer loop includes activities such as code merge, automated code review, test execution, deployment, and release.

## Inner Loop
The inner loop is everything prior to code being pushed to git and represents the core coding (day-to-day activities), testing, and debugging activities that developers perform as they work on the details of the code. It is a continuous and iterative process where developers rapidly cycle through these activities to make incremental improvements and ensure the code's quality. The goal of the inner loop is to ensure that the codebase remains stable and reliable while quickly responding to changes, fixing issues, and delivering updates to the software product. It is a fundamental part of modern software development practices and contributes to the agility and responsiveness of development teams.

### Cloud Workstations

Test locally from the `/app` directory with `python app.py`.

### Skaffold

### Emulators
To simplify development, in particular prototyping and testing apps a number of local emulation options exist.

Two areas of emulation exists for Google Cloud solutions, firstly Google Cloud products and secondly Firebase products (which are actually Google Cloud Products).


#### `gcloud`


`gcloud emulator -h`

`gcloud alpha emulator -h`

`gcloud alpha emulator pubsub start`

```
Executing: /usr/lib/google-cloud-sdk/platform/pubsub-emulator/bin/cloud-pubsub-emulator --host=localhost --port=8085
[pubsub] This is the Google Pub/Sub fake.
[pubsub] Implementation may be incomplete or differ from the real system.
[pubsub] Feb 05, 2024 10:21:14 AM com.google.cloud.pubsub.testing.v1.Main main
[pubsub] INFO: IAM integration is disabled. IAM policy methods and ACL checks are not supported
[pubsub] SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
[pubsub] SLF4J: Defaulting to no-operation (NOP) logger implementation
[pubsub] SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.
[pubsub] Feb 05, 2024 10:21:15 AM com.google.cloud.pubsub.testing.v1.Main main
[pubsub] INFO: Server started, listening on 8085
```

#### `firebase`
The Firebase Emulator Suite (as of time of writing) consists of;
* Hosting
* Cloud Functions
* Realtime Database
* Firestore
* Auth Emulator
* Cloud Storage
* Cloud Pub/Sub
* Extenstions

To spin up an emulator you must first have the firebase CLI installed and run either `firebase init` or have `firebase.json` in the root of the project.

```
firebase init

     ######## #### ########  ######## ########     ###     ######  ########
     ##        ##  ##     ## ##       ##     ##  ##   ##  ##       ##
     ######    ##  ########  ######   ########  #########  ######  ######
     ##        ##  ##    ##  ##       ##     ## ##     ##       ## ##
     ##       #### ##     ## ######## ########  ##     ##  ######  ########

You're about to initialize a Firebase project in this directory:

  /home/user/workspace

? Which Firebase features do you want to set up for this directory? Press Space to select features, then Enter to confirm your choices. Emulators: Set up local emulators for Firebase products

=== Project Setup

First, let's associate this project directory with a Firebase project.
You can create multiple project aliases by running firebase use --add, 
but for now we'll just set up a default project.

? Please select an option: Don't set up a default project

=== Emulators Setup
? Which Firebase emulators do you want to set up? Press Space to select emulators, then Enter to confirm your choices. Authentication Emulator, Functions Emulator, Firestore Emulator, Database Emulator, Hosting Emulator, Pub/Sub Emulator, Storage 
Emulator, Eventarc Emulator
? Which port do you want to use for the auth emulator? 9099
? Which port do you want to use for the functions emulator? 5001
? Which port do you want to use for the firestore emulator? 8080
? Which port do you want to use for the database emulator? 9000
? Which port do you want to use for the hosting emulator? 5000
? Which port do you want to use for the pubsub emulator? 8085
? Which port do you want to use for the storage emulator? 9199
? Which port do you want to use for the eventarc emulator? 9299
? Would you like to enable the Emulator UI? Yes
? Which port do you want to use for the Emulator UI (leave empty to use any available port)? 
? Would you like to download the emulators now? Yes

i  firestore: downloading cloud-firestore-emulator-v1.18.2.jar...
Progress: ====================================================================================================================================================================================================================================> (100% of 64MB)
i  database: downloading firebase-database-emulator-v4.11.2.jar...
Progress: ====================================================================================================================================================================================================================================> (100% of 35MB)
i  pubsub: downloading pubsub-emulator-0.7.1.zip...
Progress: ====================================================================================================================================================================================================================================> (100% of 66MB)
i  storage: downloading cloud-storage-rules-runtime-v1.1.3.jar...
Progress: ====================================================================================================================================================================================================================================> (100% of 53MB)
i  ui: downloading ui-v1.11.7.zip...

i  Writing configuration info to firebase.json...
i  Writing project information to .firebaserc...
i  Writing gitignore file to .gitignore...

✔  Firebase initialization complete!
```


`firebase emulators:start`

```

```
`firebase emulators:start --only hosting`

![Firebase YouTube Emulation Discussion](https://youtu.be/pkgvFNPdiEs?si=fDStMudUQ2MvZNJC)

UI is available at `http://localhost:4000`


### Local build and testing 

Cloud Code -> Cloud Run -> Run app on local emulator

OR

Open the command palette (press Ctrl/Cmd+Shift+P or click View > Command Palette) and then run the Run on Cloud Run Emulator command.

`cd app`
`gcloud beta code dev`

## Outer Loop
Once things have been pushed to git the outer loop takes over. The "outer loop" refers to the broader and higher-level phases or activities that are part of the software development life cycle (SDLC) and within DevOps practices, the "outer loop" can be related to activities related to integration, testing, release, and deployment. 

### Build Image

`gcloud builds submit --tag europe-docker.pkg.dev/secure-cicd-pipeline/hello-coffee/coffee:latest`

Show the build in Cloud Build (quick overview of the UI)
Show the image in AR - also show AR features and opens if setup a new reg


What to look at

### Automate Image build (Cloud build)

show the trigger by making a change (PR)

Two exist - one will create and image and the other will create AND push to CR

### Get into the hands of users (Cloud Deploy)

Cloud Deploy Candidate proposed 

Prep is to create the deploy pipeline;
`gcloud deploy apply --file=clouddeploy.yaml --region=us-east1`

`gcloud deploy releases promote --release=dev-service --delivery-pipeline=run-app-pipeline --region=us-east1`

Create a release 
```
gcloud deploy releases create "initial" --delivery-pipeline="v60-coffee" --region="us-east1" --images="app=europe-docker.pkg.dev/secure-cicd-pipeline/hello-coffee/coffee:latest"
```

```
gcloud deploy releases promote --release=cepf-dev-service --delivery-pipeline=run-app-pipeline --region=us-east1

```

Progressinve rollout


### But what about security?

#### Assured OSS

#### BinAuth

`gcloud auth configure-docker europe-docker.pkg.dev`

docker build -t europe-docker.pkg.dev/coffee-and-codey/hello-coffee/coffee:dodgy .
docker push europe-docker.pkg.dev/coffee-and-codey/hello-coffee/coffee:dodgy


#### SLSA


## Env Setup

```
gcloud services enable \
  artifactregistry.googleapis.com \
  binaryauthorization.googleapis.com \
  cloudkms.googleapis.com \
  container.googleapis.com \
  containerregistry.googleapis.com \
  containersecurity.googleapis.com
```

## Graveyard


### Setup aspects
Argolis Fixes;
gcloud projects add-iam-policy-binding <project> \
--member="serviceAccount:<project_id>-compute@developer.gserviceaccount.com" \
--role='roles/logging.logWriter'


### Skaffold Playpen/Notes
minikube start


git clone ..
cloudshell open-workspace .


skaffold dev

minikube tunnel

kubectl get service


curl http://EXTERNAL_IP:8080



gcloud builds submit \
    --region=us-west2 --config \
    cloudbuild.yaml


