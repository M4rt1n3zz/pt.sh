# Probe target

A simple Bash script to check the status of URLs, reporting whether they are active or inactive. The script supports checking a single URL or a list of URLs from a file.

## Features

- Checks both HTTP and HTTPS versions of the URL.
- Customizable timeout for each request.
- Outputs active and inactive URLs with HTTP status codes.
- Supports reading URLs from a file.

## Prerequisites

- Bash
- `curl` (for making HTTP requests)

## Usage

You can use the script in two ways:

**Check a single URL:**

```bash
   ./pt.sh <url>
```
Check a list of URLs from a file:
```
./pt.sh -l <list_file>
```
###Options
-l <list_file>: Specify a file containing URLs (one per line) to check.
-t <timeout>: Specify a timeout in seconds for the request (default is 15 seconds).
###Examples
Check a single URL:

```
./pt.sh example.com
```
Check a list of URLs from a file:

```
./pt.sh -l urls.txt -t 10
```
###Output
The script will output the status of each URL checked:

Active URLs will be listed with their HTTP status codes.
Inactive URLs will be indicated with a message stating they are not active.