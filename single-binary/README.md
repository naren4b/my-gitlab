# Install a KIND Cluster
```
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```

# Install nginx ingress-controller

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl get pod -n ingress-nginx  
```

# Install haproxy ingress-controller
```
helm repo add haproxy-ingress https://haproxy-ingress.github.io/charts
helm repo update
helm upgrade --install ingress haproxy-ingress/haproxy-ingress --set controller.hostNetwork=true --set controller.ingressClassResource.enabled=true --set controller.ingressClassResource.default=true --timeout 600s --create-namespace --namespace ingress-controller

```

# Install the gitlab

```
helm upgrade --install gitlab . --timeout 600s --create-namespace --namespace gitlab

```

# Get the root password

```
k exec -it -n gitlab gitlab-regional-0 --  grep 'Password:' /etc/gitlab/initial_root_password
```

