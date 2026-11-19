#!/usr/bin/env bash

log_file=access.log
: > "$log_file"

for ((i = 1; i <= 300; i++)); do
    case $(((i - 1) % 10)) in
        0|1|2|3) ip=192.168.1.10 ;;
        4|5|6) ip=10.0.0.5 ;;
        7|8) ip=172.16.0.20 ;;
        9) ip=203.0.113.9 ;;
    esac

    case $(((i - 1) % 20)) in
        15) status=401 ;;
        16|17) status=404 ;;
        18) status=500 ;;
        19) status=503 ;;
        *) status=200 ;;
    esac

    if (( i % 5 == 0 )); then
        method=POST
        path=/api/login
    else
        method=GET
        path=/api/users
    fi

    elapsed_seconds=$((31 + i))
    minute=$((15 + elapsed_seconds / 60))
    second=$((elapsed_seconds % 60))
    printf '%s - - [15/Aug/2026:10:%02d:%02d] "%s %s HTTP/1.1" %s\n' \
        "$ip" "$minute" "$second" "$method" "$path" "$status" >> "$log_file"
done

ip_regex='^[0-9]{1,3}(\.[0-9]{1,3}){3}'
log_regex='^[0-9]{1,3}(\.[0-9]{1,3}){3} - - \[[^ ]+\] "[A-Z]+ [^"]+ HTTP/1\.[01]" [0-9]{3}$'
total_requests=$(grep -Ec "$log_regex" "$log_file" || true)
top_ips=$(grep -Eo "$ip_regex" "$log_file" | sort | uniq -c | sort -nr | head -n 3)
count_4xx=$(grep -E "$log_regex" "$log_file" | awk '$NF ~ /^4[0-9][0-9]$/ { count++ } END { print count + 0 }')
count_5xx=$(grep -E "$log_regex" "$log_file" | awk '$NF ~ /^5[0-9][0-9]$/ { count++ } END { print count + 0 }')

printf 'Сгенерирован файл %s (строк: 300)\n' "$log_file"
printf 'Всего запросов: %s\n' "$total_requests"
printf 'Топ-3 IP-адреса:\n%s\n' "$top_ips"
printf 'Запросов с кодами 4xx: %s\n' "$count_4xx"
printf 'Запросов с кодами 5xx: %s\n' "$count_5xx"
