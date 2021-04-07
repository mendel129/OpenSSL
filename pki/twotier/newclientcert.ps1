$commonname="uniqueidentifier"

$subject="/CN=$($commonname)"
.\openssl genpkey -algorithm ec -pkeyopt ec_paramgen_curve:prime256v1 -pkeyopt ec_param_enc:named_curve -out leafs/private/endentity_$($domainname).key
.\openssl req -config IssuingCATemplate.cnf -key leafs/private/endentity_$($domainname).key -subj $subject -new -sha256 -out leafs/csr/endentity_$($domainname).csr
$interpass = get-content intermediate/private/pass
.\openssl ca -passin pass:$interpass -config IssuingCATemplate.cnf -days 375 -extensions CustomPKIClientAuthN -notext -md sha256 -in leafs/csr/endentity_$($domainname).csr -out leafs/endentity_$($domainname).cert -batch
