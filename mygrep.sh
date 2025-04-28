#!/bin/env bash

green=$'\033[0;32m'
red=$'\033[0;31m'
reset=$'\033[0m'

print_help () {
    cat << EOF

Usage: $0 [OPTION]... PATTERNS [FILE]...
--------------------------------------------------
mini version of grep command
Search for a string (case-insensitive) and print matching lines from a text file

Example:
  $0 "hello" file.txt
  $0 -n "hello" file.txt
  $0 -vn "hello" file.txt

options:
  -h, --help                        display this help and exit
  -n, --line-number                 print line number with output lines
  -v, --invert-match                select non-matching lines.
EOF
    exit 0
}

line_number=false
invert_match=false

if [ $# -eq 0 ]; then
    echo "No arguments provided. Use -h or --help for usage information."
    exit 1
fi

# for arg in "$@"; do
#     case "$arg" in
#         -h | --help) print_help ;;
#         -n | --line-number) line_number=true ;;
#         -v | --invert-match) invert_match=true ;;
#     esac
# done

while getopts ":hnv" opt; do
    case $opt in
        h) print_help ;;
        n) line_number=true ;;
        v) invert_match=true ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
    esac
done
# Remove options from the positional parameters
shift $((OPTIND - 1))

if [ $# -lt 2 ]; then
    echo "Error: missing PATTERN or FILE" >&2
    echo "Try '$0 --help' for more information." >&2
    exit 1
fi

pattern="$1"
file="$2"

if [ ! -f "$file" ]; then
    echo "File not found: $file"
    exit 1
fi

line_num=0

while IFS= read -r line; do
    line_num=$((line_num + 1))
    if [[ ${line,,} =~ ${pattern,,} ]]; then
        if $invert_match; then
            continue
        fi
        highlighted_line=$(echo "$line" | sed -E "s/(${pattern})/${red}\1${reset}/Ig")
        if $line_number; then
            printf "${green}%d:${reset} %s\n" "$line_num" "$highlighted_line"
        else
            printf "%s\n" "$highlighted_line"
        fi
    elif $invert_match; then
        if $line_number; then
            printf "${green}%d:${reset} %s\n" "$line_num" "$line"
        else
            printf "%s\n" "$line"
        fi
    fi
done < "$file"
            
