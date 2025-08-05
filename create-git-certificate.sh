DOMAIN=naren.local # TODO Change this  
mkdir -p $DOMAIN
CERT_DIR=$DOMAIN

SERVICE_NAME=git # TODO change it 
mkdir -p $CERT_DIR/$SERVICE_NAME

# Client key and csr
openssl req -new -newkey rsa:2048 -keyout $CERT_DIR/${SERVICE_NAME}/${SERVICE_NAME}.key -out $CERT_DIR/${SERVICE_NAME}/${SERVICE_NAME}.csr -nodes -subj "/CN=${SERVICE_NAME}"

echo "${SERVICE_NAME} service key and csr created at $CERT_DIR/$SERVICE_NAME "

# Client Certificate 
openssl x509 -req -CA $CERT_DIR/ca.crt -CAkey $CERT_DIR/ca.key \
                  -days 365  -set_serial 01 -CAcreateserial -extfile $CERT_DIR/domain.ext \
                  -in $CERT_DIR/${SERVICE_NAME}/${SERVICE_NAME}.csr -out $CERT_DIR/${SERVICE_NAME}/${SERVICE_NAME}.crt

echo Client key and csr create at  $CERT_DIR/${SERVICE_NAME}
ls $CERT_DIR/${SERVICE_NAME}/${SERVICE_NAME}.key
ls $CERT_DIR/${SERVICE_NAME}/${SERVICE_NAME}.csr

echo "${SERVICE_NAME} service certificate created at $CERT_DIR/$SERVICE_NAME/ "
ls $CERT_DIR/${SERVICE_NAME}/${SERVICE_NAME}.crt
