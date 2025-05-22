Here’s a clear summary of all useful commands you've used to manage your MicroK8s Helm deployments and fix issues:

### ✅ **MicroK8s Basic Commands**

- Check cluster status:
```bash
microk8s status --wait-ready
```

- Enable essential add-ons:
```bash
microk8s enable dns storage ingress
```

### ✅ **Helm Commands (MicroK8s)**

- Update Helm repositories:
```bash
microk8s helm3 repo update
```

- Install Elasticsearch:
```bash
microk8s helm3 install elasticsearch elastic/elasticsearch \
  --set replicas=1,minimumMasterNodes=1
```

- Install Kibana (NodePort):
```bash
microk8s helm3 install kibana elastic/kibana \
  --set service.type=NodePort
```

- List existing Helm releases:
```bash
microk8s helm3 list --all-namespaces
```

- Uninstall Helm release (clean removal):
```bash
microk8s helm3 uninstall kibana --no-hooks
```

### ✅ **Resolving Helm Installation Conflicts**

If you encounter conflicts, explicitly delete resources:

- Delete conflicting `role` and `rolebinding`:
```bash
microk8s kubectl delete role pre-install-kibana-kibana
microk8s kubectl delete rolebinding pre-install-kibana-kibana
```

- Delete conflicting ServiceAccount:
```bash
microk8s kubectl delete serviceaccount pre-install-kibana-kibana --ignore-not-found
```

- Delete conflicting ConfigMap:
```bash
microk8s kubectl delete configmap kibana-kibana-helm-scripts
```

- Force-remove a stuck Helm release:
```bash
microk8s helm3 uninstall kibana --no-hooks --ignore-not-found
```

### ✅ **Check for Leftover Resources (general troubleshooting):**
```bash
microk8s kubectl get all,role,rolebinding,sa,pvc,configmap -l app=kibana
```

### ✅ **Deploy Demo Application**

Simple deployment for testing:

`demo-app.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-nginx
  template:
    metadata:
      labels:
        app: kibana-demo
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

Deploy the demo app:
```bash
microk8s kubectl apply -f demo-app.yaml
```

---

### 🚨 **Next Step:**

Ensure all previous resources (`roles`, `serviceaccounts`, `rolebindings`, and `configmaps`) have been deleted successfully, and retry your Helm installation command.

Let me know if you hit further issues!
