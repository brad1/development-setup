# EKS Downward API Python Demo

This package shows how to run a small Python script in EKS and print real pod-visible values.

The important split:

- `deployment.yaml` wires Kubernetes metadata into the container.
- `app.py` reads those values and prints structured JSON logs.
- `Dockerfile` packages the Python script into a container image.

## Files

```text
app.py
Dockerfile
deployment.yaml
README.md
```

## What this demo prints

The app prints values such as:

- pod name
- namespace
- pod UID
- node name
- service account name
- pod IP
- host IP
- Kubernetes API service host
- optional IRSA-related AWS values, if configured

It does not magically know higher-level AWS resources like VPC, subnet, target group, or load balancer. Those are outside the normal container view unless you inject them or call AWS/Kubernetes APIs.

---

# AWS Console path

## 1. Create an EKS cluster

1. Open AWS Console.
2. Go to **Elastic Kubernetes Service / EKS**.
3. Choose **Create cluster**.
4. Enter a cluster name.
5. Select or create the required EKS cluster IAM role.
6. Choose networking defaults for a first test, unless your org requires a specific VPC/subnet setup.
7. Create the cluster.
8. Wait until the cluster status is **Active**.

## 2. Add worker nodes

1. Open the cluster.
2. Go to the **Compute** tab.
3. Choose **Add node group**.
4. Select or create the node IAM role.
5. Use a small test size, for example 2 nodes.
6. Create the node group.
7. Wait until the node group status is **Active**.

## 3. Create an ECR repository

1. Go to **Elastic Container Registry / ECR**.
2. Choose **Create repository**.
3. Repository name:

```text
eks-downward-api-python-demo
```

4. Create the repository.
5. Open the repository and use **View push commands** if you want AWS to show account-specific Docker commands.

---

# CLI path from AWS CloudShell or your workstation

Replace these values:

```bash
export AWS_REGION=us-east-1
export CLUSTER_NAME=your-cluster-name
export ACCOUNT_ID=123456789012
export ECR_REPO=eks-downward-api-python-demo
```

## 1. Confirm AWS identity

```bash
aws sts get-caller-identity
```

## 2. Connect kubectl to your EKS cluster

```bash
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"
kubectl get nodes
```

## 3. Create the ECR repository

```bash
aws ecr create-repository \
  --repository-name "$ECR_REPO" \
  --region "$AWS_REGION"
```

If it already exists, that is fine.

## 4. Build the Docker image

Run this from the folder containing `Dockerfile` and `app.py`.

```bash
docker build -t "$ECR_REPO:latest" .
```

## 5. Log Docker into ECR

```bash
aws ecr get-login-password --region "$AWS_REGION" \
  | docker login \
      --username AWS \
      --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
```

## 6. Tag and push the image

```bash
docker tag "$ECR_REPO:latest" \
  "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest"

docker push "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest"
```

## 7. Edit deployment.yaml

Replace:

```text
REPLACE_WITH_YOUR_ECR_IMAGE_URI
```

with:

```text
123456789012.dkr.ecr.us-east-1.amazonaws.com/eks-downward-api-python-demo:latest
```

Use your real account ID and region.

## 8. Deploy to EKS

```bash
kubectl apply -f deployment.yaml
```

## 9. Check pod status

```bash
kubectl get pods
```

## 10. View logs

```bash
kubectl logs deployment/eks-downward-api-python-demo
```

Expected shape:

```json
{"event":"eks_term_observed","term":"pod","present":true,"value":"eks-downward-api-python-demo-...","source":"downward_api_env:metadata.name"}
{"event":"eks_term_observed","term":"namespace","present":true,"value":"default","source":"downward_api_env:metadata.namespace"}
{"event":"eks_term_observed","term":"node","present":true,"value":"ip-...","source":"downward_api_env:spec.nodeName"}
```

---

# Optional ConfigMap and Secret test

Create a ConfigMap:

```bash
kubectl create configmap app-config \
  --from-literal=APP_CONFIG="hello-from-configmap"
```

Create a Secret:

```bash
kubectl create secret generic app-secret \
  --from-literal=DB_PASSWORD="demo-password"
```

Then uncomment the `APP_CONFIG` and `DB_PASSWORD` environment variable blocks in `deployment.yaml`.

Apply again:

```bash
kubectl apply -f deployment.yaml
kubectl rollout restart deployment/eks-downward-api-python-demo
kubectl logs deployment/eks-downward-api-python-demo
```

Do not log real production secrets. This demo only logs whether `DB_PASSWORD` is set.

---

# Cleanup

```bash
kubectl delete -f deployment.yaml
aws ecr delete-repository \
  --repository-name "$ECR_REPO" \
  --region "$AWS_REGION" \
  --force
```

Delete the EKS node group and cluster from the AWS Console when finished to avoid ongoing charges.

---

# Notes

Kubernetes Downward API can expose selected pod and container fields through environment variables or mounted files. This demo uses environment variables because they are simple and easy to inspect.

Official references:

- Amazon EKS getting started with AWS Management Console and AWS CLI:
  https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html

- Amazon ECR image push:
  https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html

- Kubernetes Downward API:
  https://kubernetes.io/docs/concepts/workloads/pods/downward-api/

- Kubernetes Downward API environment variable task:
  https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/
