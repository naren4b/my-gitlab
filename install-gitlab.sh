export DOMAIN=naren.local # TODO Change this  
export CERT_DIR=$DOMAIN
export SERVICE_NAME=git # TODO change it 
export NS="gitlab"
export STORAGE_CLASS="local-path"
export ING_CLASS="nginx"


git clone https://github.com/naren4b/my-gitlab.git
cd my-gitlab

bash create-root-certificate.sh
bash create-git-certificate.sh

kubectl create namespace $NS
kubectl create secret generic -n $NS gitlab-tls-secret \
            --from-file=tls.crt=$CERT_DIR/$SERVICE_NAME/$SERVICE_NAME.crt \
            --from-file=tls.key=$CERT_DIR/$SERVICE_NAME/$SERVICE_NAME.key \
            --from-file=ca.crt=$CERT_DIR/ca.crt  -o yaml > gitlab-tls-secret.yaml


cat<<EOF > single-binary/my-values.yaml
git:
  regional:
    image_repo: gitlab/gitlab-ce
    version_tag: 17.1.6-ce.0
    host: "git.${DOMAIN}" 
    ingressClassName: "${ING_CLASS}" # TODO
    namespace: ${NS} 
    storage_class: "{STORAGE_CLASS}" # TODO 
    s3_endpoint: ""
    s3_location: us-west-1
    s3_bucket_name: ""
    s3_access_key: ""
    s3_secret_key: ""
    restore:
      enable: false
      snapshot_file_name: regional_gitlab_backup.tar
EOF

helm upgrade --install gitlab . --timeout 600s --create-namespace --namespace ${NS}