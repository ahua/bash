#!/usr/bin/env bash

openssl genrsa -out private.pem 1024
openssl rsa -in private.pem -out public.pem -outform PEM -pubout
echo 'too many secrets' > file.txt
openssl rsautl -encrypt -inkey public.pem -pubin -in file.txt -out file.ssl
cat file.ssl | base64 > file.base64
cat file.base64 | base64 -d > file.ssl2
openssl rsautl -decrypt -inkey private.pem -in file.ssl2 -out decrypted.txt


