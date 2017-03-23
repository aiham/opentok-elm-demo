#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

mkdir -p "${DIR}/ssl"
cd "${DIR}/ssl"

openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes

echo 'Done.'
