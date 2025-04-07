# Tutorial: From Local Node App to Helm-Deployed Pod on GKE

Sample repo using docker image creatino and pushing it to hlem


## 1. 🧱 Create a Node.js App

We built a simple Express server to simulate a service:
[index.js](app/index.js)

**Why?**
To have an application we can package, ship, and deploy in a repeatable way.

## 2. 🐳 Create a Dockerfile

[Dockerfile](Dockerfile)

**Why do we need this?**
The Dockerfile defines how to package our app into a Docker image — a portable, reproducible unit with code + runtime + dependencies.

## 3. 📦 Create a docker-compose.yml

[docker-compose.yml](docker-compose.yml)

**Why use docker-compose?**
It simplifies running multi-container setups locally, but here we just used it to test that our container runs correctly on our machine before deploying.

## 4. ⬆️ Build and Push to Docker Hub

    docker build -t your-dockerhub-username/docker-sample-app:latest .
    docker login
    docker push your-dockerhub-username/docker-sample-app:latest

**Why push to Docker Hub?**
Kubernetes (via Helm) needs a registry to pull images from. By pushing to Docker Hub, we make the image accessible from your GKE cluster.

## 5. 🎛️ Create a Helm Chart

    helm create myapp

This scaffolds a chart with Kubernetes manifests in myapp/templates.

**Why use Helm?**
Helm lets us package, configure, and deploy Kubernetes apps with reusability and flexibility (like environment overrides and templating).

## 6. 🛠️ Override Helm Values with values.yaml or myvalues.yaml

```yaml
image:
  repository: your-dockerhub-username/docker-sample-app
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 3000

containerPort: 3000

```

Update deployment.yaml and service.yaml to use these values.

**Why override values?**
This allows per-environment config (dev, staging, prod) without changing the chart templates — values are injected dynamically during install.

## 7. 🚀 Deploy to GKE with Helm

    helm install myapp ./myapp -f myvalues.yaml

What happened here?

✅ Helm generated Kubernetes manifests from your chart and values
✅ Helm sent those manifests to GKE
✅ GKE's Autopilot mode auto-injected default CPU/memory since none were specified
✅ Your container image was pulled from Docker Hub
✅ The deployment and service were created successfully

## 8. 🔌 Port Forward and Access App

Helm provides instructions to access your service locally:

```shell
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=myapp,app.kubernetes.io/instance=myapp" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
```

Then open http://localhost:8080 — you'll see: "Hello from Docker!"

## Summary

| Step | Tool/Concept     | Purpose             |
|------|------------------|---------------------|
| 1    | Node.js          | App logic           |
| 2    | Dockerfile       | Define image        |
| 3    | docker-compose   | Local test          |
| 4    | Docker Hub       | Share image         |
| 5    | Helm chart       | Package deployment  |
| 6    | myvalues.yaml    | Override config     |
| 7    | Helm install     | Deploy to GKE       |
| 8    | Port forward     | Access app          |
