#!/usr/bin/env bash

echo "$*" > /usr/local/apache2/bin/httpd

exec "$@"
