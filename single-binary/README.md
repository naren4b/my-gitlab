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

# Install ArgoCD

# Get your Custom Certificate

#### Root CA

```
openssl req -x509 -sha256 -newkey rsa:2048  -keyout rootCA.key -out rootCA.crt \
            -days 356 -nodes -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Naren/CN=gitlab.127.0.0.1.nip.io"
```

#### Client key and csr

```
openssl req -new -newkey rsa:2048 -keyout gitlab.key -out gitlab.csr -nodes -subj "/CN=gitlab.127.0.0.1.nip.io"
```

#### Setup the Signing

```
cat >domain.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.127.0.0.1.nip.io
EOF
```

#Sign Client csr and generate crt

```
openssl x509 -req -CA rootCA.crt -CAkey rootCA.key \
                  -days 365  -set_serial 01 -CAcreateserial -extfile domain.ext \
                  -in gitlab.csr -out gitlab.crt
```

# Create the secret

```
kubectl create secret tls gitlab-tls-secret --key gitlab.key --cert gitlab.crt --dry-run=client -o yaml
```

\*copy the tls.crt and tls.key to the value file

# Install ingress controller

```
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
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

# Configure the gitlab

get the [gitlab.rb](resources/gitlab.rb)

```

kubectl cp gitlab.rb gitlab-regional-0://etc/gitlab/gitlab.rb -n gitlab

#gitlab-ctl reconfigure and gitlab-ctl restart
kubectl exec -it gitlab-regional-0 -n gitlab -- gitlab-ctl reconfigure
kubectl exec -it gitlab-regional-0 -n gitlab -- gitlab-ctl restart
```

# Testing

```
export GIT_SSL_NO_VERIFY=1
k exec -it -n gitlab gitlab-regional-0 --  grep 'Password:' /etc/gitlab/initial_root_password
git clone http://root@gitlab.127.0..0.1.nip.io/demo/demo-app.git
echo "Hello" + `date` > README.md
git add -A
git commit -m "my first commit"
git push
```

ref: https://docs.gitlab.com/ee/install/docker/installation.html
