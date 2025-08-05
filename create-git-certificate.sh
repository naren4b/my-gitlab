# Create git TLS Certificate 
mkdir -p $CERT_DIR/$GIT_SERVICE_NAME

# Client key and csr
openssl req -new -newkey rsa:2048 -keyout $CERT_DIR/${GIT_SERVICE_NAME}/${GIT_SERVICE_NAME}.key -out $CERT_DIR/${GIT_SERVICE_NAME}/${GIT_SERVICE_NAME}.csr -nodes -subj "/CN=${GIT_SERVICE_NAME}"

echo "${GIT_SERVICE_NAME} service key and csr created at $CERT_DIR/$GIT_SERVICE_NAME "

# Client Certificate 
openssl x509 -req -CA $CERT_DIR/ca.crt -CAkey $CERT_DIR/ca.key \
                  -days 365  -set_serial 01 -CAcreateserial -extfile $CERT_DIR/domain.ext \
                  -in $CERT_DIR/${GIT_SERVICE_NAME}/${GIT_SERVICE_NAME}.csr -out $CERT_DIR/${GIT_SERVICE_NAME}/${GIT_SERVICE_NAME}.crt

echo Client key and csr create at  $CERT_DIR/${GIT_SERVICE_NAME}
ls $CERT_DIR/${GIT_SERVICE_NAME}/${GIT_SERVICE_NAME}.key
ls $CERT_DIR/${GIT_SERVICE_NAME}/${GIT_SERVICE_NAME}.csr

echo "${GIT_SERVICE_NAME} service certificate created at $CERT_DIR/$GIT_SERVICE_NAME/ "
ls $CERT_DIR/${GIT_SERVICE_NAME}/${GIT_SERVICE_NAME}.crt
