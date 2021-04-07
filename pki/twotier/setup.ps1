#Last modified 2021/04/07
#Based upon https://tools.ietf.org/id/draft-moskowitz-ecdsa-pki-09.html

mkdir root
mkdir root/certs
mkdir root/crl
mkdir root/private
mkdir root/newcerts
new-item root/index.txt
1000 | Out-File -Encoding Oem root/serial
$rootpass=.\openssl rand -base64 33
$rootpass | out-file root/private/pass
.\openssl genpkey -aes256 -algorithm ec -pkeyopt ec_paramgen_curve:prime256v1 -outform pem -pkeyopt ec_param_enc:named_curve -out root/private/cakey.pem -pass pass:$rootpass
$sn="1"
.\openssl req -config RootCATemplate.cnf -passin pass:$rootpass -set_serial $sn -keyform pem -outform pem -key root/private/cakey.pem -subj "/C=BE/ST=Antwerp/L=Antwerp/O=TEST/CN=DEMO Root Certification Authority/emailAddress=email@tld.com" -new -x509 -days 7300 -sha256 -extensions v3_ca -out root/cacert.pem


mkdir intermediate
mkdir intermediate/private
mkdir intermediate/csr
mkdir intermediate/newcerts
mkdir intermediate/certs
new-item intermediate/index.txt
1000 | Out-File -Encoding Oem intermediate/serial
$interpass=.\openssl rand -base64 33
$interpass | out-file intermediate/private/pass
.\openssl genpkey -pass pass:$interpass -aes256 -algorithm ec -pkeyopt ec_paramgen_curve:prime256v1 -outform pem -pkeyopt ec_param_enc:named_curve -out intermediate/private/cakey.pem
.\openssl req -config RootCATemplate.cnf -passin pass:$interpass -key intermediate/private/cakey.pem -batch -keyform pem -outform pem -subj "/C=BE/ST=Antwerp/L=Antwerp/O=TEST/CN=DEMO Root Certification Authority/emailAddress=email@tld.com" -new -sha256 -out intermediate/csr/intermediate.csr
.\openssl ca -config RootCATemplate.cnf -days 3650 -passin pass:$rootpass -extensions v3_intermediate_ca -notext -md sha256 -batch -in intermediate/csr/intermediate.csr -out intermediate/cacert.pem


mkdir leafs
mkdir leafs/private
mkdir leafs/csr
$subject="/CN=confirmation_certificate"
.\openssl genpkey -algorithm ec -pkeyopt ec_paramgen_curve:prime256v1 -pkeyopt ec_param_enc:named_curve -out leafs/private/endentity.key
.\openssl req -config IssuingCATemplate.cnf -key leafs/private/endentity.key -subj $subject -new -sha256 -out leafs/csr/endentity.csr
.\openssl ca -passin pass:$interpass -config openssl_issuing.cnf -days 375 -extensions CustomPKIServerCert -notext -md sha256 -in leafs/csr/endentity.csr -out leafs/endentity.cert -batch
