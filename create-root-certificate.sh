# Create Certificate 

mkdir -p $CERT_DIR

# root certificate 
openssl req -x509 -sha256 -newkey rsa:2048  -keyout $CERT_DIR/ca.key -out $CERT_DIR/ca.crt \
                -days 356 -nodes -subj "/C=IN/ST=Karnataka/L=Bangalore/O=Naren/CN=${DOMAIN}"

echo "Root Certificate Created at $CERT_DIR/"
ls $CERT_DIR/ca.crt
ls $CERT_DIR/ca.key

cat >$CERT_DIR/domain.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.$DOMAIN
EOF
