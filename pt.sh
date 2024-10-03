#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

active_urls=()
inactive_urls=()
checked_urls=()

max_time=15

is_checked() {
  local url=$1
  for checked_url in "${checked_urls[@]}"; do
    if [[ "$checked_url" == "$url" ]]; then
      return 0
    fi
  done
  return 1
}

check_url() {
  local url=$1

  if is_checked "$url"; then
    return
  fi

  response=$(curl -Isk --max-time "$max_time" "http://$url" 2>/dev/null)
  http_status=$(echo "$response" | grep "HTTP/" | awk '{print $2}')

  if [[ -n "$http_status" ]]; then
    echo -e "${GREEN}[+] Active - $http_status:${NC} http://$url"
    echo "$response" | head -n 10
    active_urls+=("http://$url ($http_status)")
    checked_urls+=("$url")
  else
    response=$(curl -Isk --max-time "$max_time" "https://$url" 2>/dev/null)
    http_status=$(echo "$response" | grep "HTTP/" | awk '{print $2}')
    if [[ -n "$http_status" ]]; then
      echo -e "${GREEN}[+] Active - $http_status:${NC} https://$url"
      echo "$response" | head -n 10
      active_urls+=("https://$url ($http_status)")
      checked_urls+=("$url")
    else
      echo -e "${RED}[-] Not Active:${NC} $url"
      inactive_urls+=("$url")
      checked_urls+=("$url")
    fi
  fi
}

check_list() {
  local file=$1
  if [[ -f $file ]]; then
    while IFS= read -r line; do
      if [[ -n "$line" ]]; then
        check_url "$line"
      fi
    done < "$file"
  else
    echo "File not found: $file"
    exit 1
  fi
}


while getopts "l:t:" opt; do
  case $opt in
    l)
      list_file=$OPTARG
      ;;
    t)
      max_time=$OPTARG
      ;;
    *)
      echo "Usage: $0 [-t <timeout>] <url> or $0 -l <list_file> [-t <timeout>]"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

echo -e "${YELLOW}[!] Performing probes!${NC}"

if [[ -n "$list_file" ]]; then
  check_list "$list_file"
elif [[ ! -z "$1" ]]; then
  check_url "$1"
else
  echo "Usage: $0 [-t <timeout>] <url> or $0 -l <list_file> [-t <timeout>]"
  exit 1
fi

echo -e "\n${YELLOW}[!] Done!${NC}"
sleep 1
echo -e "\n${YELLOW}[!] Sorted results!${NC}"

if [[ ${#active_urls[@]} -gt 0 ]]; then
  echo -e "\n${GREEN}Active URLs:${NC}"
  for url in "${active_urls[@]}"; do
    echo -e "${GREEN}[+] $url${NC}"
  done
else
  echo -e "${RED}No active URLs found.${NC}"
fi

if [[ ${#inactive_urls[@]} -gt 0 ]]; then
  echo -e "\n${RED}Inactive URLs:${NC}"
  for url in "${inactive_urls[@]}"; do
    echo -e "${RED}[-] Not Active:${NC} $url"
  done
else
  echo -e "${GREEN}No inactive URLs found.${NC}"
fi