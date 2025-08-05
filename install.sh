export DOMAIN=naren.local # TODO Change this  
export CERT_DIR=$DOMAIN

export ARGOCD_SERVICE_NAME=argocd # TODO change it 
export ARGOCD_NS="argocd"

export GIT_SERVICE_NAME=git # TODO change it 
export GITLAB_NS="gitlab"

export STORAGE_CLASS="local-path"
export ING_CLASS="nginx"

bash create-root-certificate.sh

# Install Nginx 

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl get pod -n ingress-nginx 

# Install ArgoCD

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch deployments.apps -n argocd  argocd-server  \
--type=json \
-p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--insecure"}]'

bash create-argocd-certificate.sh

kubectl create namespace $ARGOCD_NS
kubectl create secret generic -n $ARGOCD_NS $ARGOCD_SERVICE_NAME-tls-secret \
            --from-file=tls.crt=$CERT_DIR/$ARGOCD_SERVICE_NAME/$ARGOCD_SERVICE_NAME.crt \
            --from-file=tls.key=$CERT_DIR/$ARGOCD_SERVICE_NAME/$ARGOCD_SERVICE_NAME.key \
            --from-file=ca.crt=$CERT_DIR/ca.crt  -o yaml > $ARGOCD_SERVICE_NAME-tls-secret.yaml


cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
  name: argocd
  namespace: argocd
spec:
  ingressClassName: ${ING_CLASS}
  rules:
  - host: argocd.${DOMAIN}
    http:
      paths:
      - backend:
          service:
            name: argocd-server
            port:
              number: 443
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - argocd.${DOMAIN}
    secretName: $ARGOCD_SERVICE_NAME-tls-secret
EOF
echo "127.0.0.1 argocd.${DOMAIN}" >> /etc/hosts


# Install Git 
git clone https://github.com/naren4b/my-gitlab.git
cd my-gitlab





bash create-git-certificate.sh

kubectl create namespace $GITLAB_NS
kubectl create secret generic -n $GITLAB_NS gitlab-tls-secret \
            --from-file=tls.crt=$CERT_DIR/$GIT_SERVICE_NAME/$GIT_SERVICE_NAME.crt \
            --from-file=tls.key=$CERT_DIR/$GIT_SERVICE_NAME/$GIT_SERVICE_NAME.key \
            --from-file=ca.crt=$CERT_DIR/ca.crt  -o yaml > gitlab-tls-secret.yaml

cd single-binary
cat<<EOF > my-values.yaml
git:
  regional:
    image_repo: gitlab/gitlab-ce
    version_tag: 17.1.6-ce.0
    host: "git.${DOMAIN}" 
    ingressClassName: "${ING_CLASS}" # TODO
    namespace: ${GITLAB_NS} 
    storage_class: "${STORAGE_CLASS}" # TODO 
    s3_endpoint: ""
    s3_location: us-west-1
    s3_bucket_name: ""
    s3_access_key: ""
    s3_secret_key: ""
    restore:
      enable: false
      snapshot_file_name: regional_gitlab_backup.tar
EOF

helm template gitlab . -f my-values.yaml --timeout 600s --create-namespace --namespace ${GITLAB_NS} > gitlab-out.yaml
helm upgrade --install gitlab . -f my-values.yaml --timeout 600s --create-namespace --namespace ${GITLAB_NS}

echo "127.0.0.1 argocd.${DOMAIN}" >> /etc/hosts

