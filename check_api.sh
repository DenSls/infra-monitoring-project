#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    printf 'Использование: %s <URL>\n' "$0" >&2
    exit 1
fi

url=$1
if [[ -z $url ]]; then
    printf 'Использование: %s <URL>\n' "$0" >&2
    exit 1
fi

http_code=$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' --connect-timeout 5 --max-time 10 -- "$url")
curl_status=$?

if [[ $curl_status -eq 0 && $http_code == 200 ]]; then
    printf 'API доступен\n'
    exit 0
fi

if [[ -z $http_code ]]; then
    http_code=000
fi
printf 'API недоступен, код ответа: %s\n' "$http_code"
exit 1
