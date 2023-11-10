

lots od steps involved
* `docker build`
* `docker tag`
* `docker push`
* `vim deploy.yml`
* `kubectl apply`
* `kubectl logs`
* `kubectl port-forward`
* `gcloud run deploy`

Wouldnt it be great to get a "hot code reload" for k8s when building the app

`skaffold dev` replaces all the above

```
apiVersion: skaffold/v4beta1
kind: Config
build:
  artifacts:
  - image: skaffold-expl-app
    docker:
      dockerfile: Dockerfile
test:
  - image: skaffold-expl-app
    custom:
     - command: echo This is a custom test command # probably query the healthcheck script in the container
       name: Custom Test
manifests:
  kustomize:
    paths:
    - kustomize/base

```

Build -> Dockerfile, JIB, Buildpacks etc.
Test -> custom test
Deploy -> K8s, CR, Helm, Kustomize

`skaffold init`
`skaffold dev`

`skaffold build` - Build, tag, push -> `artifacts.json` produced
`skaffold deploy` - `artifacts.json` -> CD (render manifests and deploy manifests)
`skaffold render` - build, tag, push. render mainfests -> output.yaml -> git (CI process and use the output to drive gitops)
`skaffold apply` - `output.yaml` -> deploy manifests (CD)