#!/bin/bash
echo "Hello v2 World!" > index.html
nohup busybox httpd -f -p ${server_port} &