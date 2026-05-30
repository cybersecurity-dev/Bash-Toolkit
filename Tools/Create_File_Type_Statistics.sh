#!/usr/bin/env bash
# =============================================================================
# create_file_type_statistics.sh
# Scans a directory and classifies files by magic number / shebang line,
# then prints a summary report with per-type counts and file lists.
#
# Detected file types:
#   ELF Binary | APK/APKX | DEX (Android) | PE (EXE/DLL) | Java Class |
#   Bash/Shell | Python | PowerShell | Ruby | Perl |
#   PCAP | PCAPng | ZIP | GZIP | TAR | 7-Zip | RAR | Other
#
# Usage:
#   ./create_file_type_statistics.sh [OPTIONS] <directory>
#
# Options:
#   -r          Recurse into sub-directories
#   -l          List every matched file under each type
#   -o <file>   Save report to a file (also prints to stdout)
#   -c          Disable colour output
#   -h          Show this help
# =============================================================================

set -euo pipefail

# ---- Colours --------------------------------------------------------------------------------------------------------------------------------------
setup_colors() {
    if $USE_COLOR; then
        RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
        CYAN='\033[0;36m'; MAGENTA='\033[0;35m'
        BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'
    else
        RED=''; GREEN=''; YELLOW=''; CYAN=''; MAGENTA=''
        BOLD=''; DIM=''; RESET=''
    fi
}

# ---- Defaults Values--------------------------------------------------------------------------------------------------------------------------------
RECURSE=false
LIST_FILES=false
OUTPUT_FILE=""
USE_COLOR=true
SCAN_DIR=""

# ---- Counters & file lists (Associative Arrays) ----------------------------------------------------------------
declare -A TYPE_COUNT
declare -A TYPE_FILES

# Ordered list of type keys for display
TYPE_KEYS=(
    "ELF"
    "APK_APKX"
    "DEX"
    "PE_EXE"
    "JAVA_CLASS"
    "BASH_SHELL"
    "PYTHON"
    "POWERSHELL"
    "RUBY"
    "PERL"
    "PCAP"
    "PCAPNG"
    "ZIP"
    "GZIP"
    "TAR"
    "7ZIP"
    "RAR"
    "OTHER"
)

declare -A TYPE_LABEL=(["ELF"]="ELF Binary (Linux/Unix)"
                       ["APK_APKX"]="APK / APKX (Android Package)"
                       ["DEX"]="DEX (Android Dalvik)"
                       ["PE_EXE"]="PE Executable (EXE/DLL)"
                       ["JAVA_CLASS"]="Java Class File"
                       ["BASH_SHELL"]="Bash / Shell Script"
                       ["PYTHON"]="Python Script"
                       ["POWERSHELL"]="PowerShell Script"
                       ["RUBY"]="Ruby Script"
                       ["PERL"]="Perl Script"
                       ["PCAP"]="PCAP Capture"
                       ["PCAPNG"]="PCAP-ng Capture"
                       ["ZIP"]="ZIP Archive"
                       ["GZIP"]="GZIP Archive"
                       ["TAR"]="TAR Archive"
                       ["7ZIP"]="7-Zip Archive"
                       ["RAR"]="RAR Archive"
                       ["OTHER"]="Other / Unknown")

# ---- Initialise counters --------------------------------------------------------------------------------------------------------------
for key in "${TYPE_KEYS[@]}"; do
    TYPE_COUNT[$key]=0
    TYPE_FILES[$key]=""
done

TOTAL=0

# ---- Help --------------------------------------------------------------------------------------------------------------------------------------------
usage() {
    grep '^#' "$0" | grep -v '^#!/' | sed 's/^# \{0,3\}//' | head -20
    exit 0
}

# ---- Dependency check --------------------------------------------------------------------------------------------------------------------
check_deps() {
    for cmd in xxd find head; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: required command '$cmd' not found." >&2
            exit 1
        fi
    done
}

# ---- Read N hex bytes from file ------------------------------------------------------------------------------------------------
get_magic() {
    local file="$1" bytes="$2"
    xxd -p -l "$bytes" "$file" 2>/dev/null | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]'
}

# ---- Read first text line (shebang) ----------------------------------------------------------------------------------------
get_shebang() {
    head -1 "$1" 2>/dev/null | tr '[:upper:]' '[:lower:]'
}

# ---- Classify a single file ------------------------------------------------------------------------------------------------------
classify_file() {
    local file="$1"
    local magic4 magic8 magic12 shebang type

    magic4=$(get_magic  "$file" 4)
    magic8=$(get_magic  "$file" 8)
    magic12=$(get_magic "$file" 12)

    # ---- Binary formats ----------------------------------------------------------------------------------------------------------------

    # ELF  -->  7f 45 4c 46
    if [[ "$magic4" == "7f454c46" ]]; then
        type="ELF"

    # DEX (Android Dalvik)  -->  64 65 78 0a  ("dex\n")
    elif [[ "$magic4" == "6465780a" ]]; then
        type="DEX"

    # PE (EXE/DLL)  -->  4d 5a  ("MZ")
    elif [[ "${magic4:0:4}" == "4d5a" ]]; then
        type="PE_EXE"

    # Java Class  -->  CA FE BA BE
    elif [[ "$magic4" == "cafebabe" ]]; then
        type="JAVA_CLASS"

    # PCAP (little-endian or big-endian)  -->  D4 C3 B2 A1 | A1 B2 C3 D4
    elif [[ "$magic4" == "d4c3b2a1" || "$magic4" == "a1b2c3d4" ]]; then
        type="PCAP"

    # PCAPng  -->  0A 0D 0D 0A
    elif [[ "$magic4" == "0a0d0d0a" ]]; then
        type="PCAPNG"

    # ZIP / APK / APKX  -->  50 4B 03 04
    elif [[ "$magic4" == "504b0304" ]]; then
        local fname
        fname=$(basename "$file")
        local ext="${fname##*.}"
        ext="${ext,,}"   # lowercase
        if [[ "$ext" == "apk" || "$ext" == "apkx" || "$ext" == "xapk" ]]; then
            type="APK_APKX"
        elif command -v unzip &>/dev/null && unzip -l "$file" 2>/dev/null | grep -q "classes\.dex"; then
            type="APK_APKX"
        else
            type="ZIP"
        fi

    # GZIP  -->  1F 8B
    elif [[ "${magic4:0:4}" == "1f8b" ]]; then
        type="GZIP"

    # TAR (ustar magic at byte offset 257)
    elif xxd -p -s 257 -l 5 "$file" 2>/dev/null | grep -qi "7573746172"; then
        type="TAR"

    # 7-Zip  -->  37 7A BC AF 27 1C
    elif [[ "${magic12:0:12}" == "377abcaf271c" ]]; then
        type="7ZIP"

    # RAR  -->  52 61 72 21 1A 07  ("Rar!")
    elif [[ "${magic12:0:12}" == "526172211a07" ]]; then
        type="RAR"

    # ---- Script / text formats (shebang line) --------------------------------------------------------------------
    else
        shebang=$(get_shebang "$file")
        if [[ "$shebang" == *"#!"* ]]; then
            if [[ "$shebang" == *"bash"* || "$shebang" == *"/sh"* ]]; then
                type="BASH_SHELL"
            elif [[ "$shebang" == *"python"* ]]; then
                type="PYTHON"
            elif [[ "$shebang" == *"pwsh"* || "$shebang" == *"powershell"* ]]; then
                type="POWERSHELL"
            elif [[ "$shebang" == *"ruby"* ]]; then
                type="RUBY"
            elif [[ "$shebang" == *"perl"* ]]; then
                type="PERL"
            else
                type="OTHER"
            fi
        else
            # No shebang — try PowerShell heuristics (UTF-16LE BOM or .ps1 extension)
            local fname ext
            fname=$(basename "$file")
            ext="${fname##*.}"; ext="${ext,,}"
            local bom
            bom=$(get_magic "$file" 2)
            if [[ "$ext" == "ps1" || "$ext" == "psm1" || "$ext" == "psd1" ||
                  "$bom" == "fffe" ]]; then
                type="POWERSHELL"
            else
                type="OTHER"
            fi
        fi
    fi

    echo "$type"
}

# ---- Record result --------------------------------------------------------------------------------------------------------------------------
record() {
    local type="$1" file="$2"
    TYPE_COUNT[$type]=$(( TYPE_COUNT[$type] + 1 ))
    if $LIST_FILES; then
        TYPE_FILES[$type]+="    $file\n"
    fi
    (( TOTAL++ )) || true
}

# ---- Scan directory ------------------------------------------------------------------------------------------------------------------------
scan() {
    local depth_opt=(-maxdepth 1)
    $RECURSE && depth_opt=()

    while IFS= read -r -d '' file; do
        [[ -f "$file" && -r "$file" ]] || continue
        local t
        t=$(classify_file "$file")
        record "$t" "$file"
    done < <(find "$SCAN_DIR" "${depth_opt[@]}" -type f -print0)
}


print_report() {
    local line
    line=$(printf '%.0s--' {1..62})

    printf "${BOLD}${CYAN}%s${RESET}\n" "$line"
    printf "${BOLD}${CYAN}  FILE TYPE REPORT — Magic Number Analysis${RESET}\n"
    printf "${BOLD}${CYAN}%s${RESET}\n" "$line"
    printf "  ${DIM}Directory : ${RESET}${YELLOW}%s${RESET}\n"   "$SCAN_DIR"
    printf "  ${DIM}Recursive : ${RESET}%s\n"                    "$RECURSE"
    printf "  ${DIM}Scanned   : ${RESET}${BOLD}%d${RESET} files\n" "$TOTAL"
    printf "${BOLD}${CYAN}%s${RESET}\n" "$line"

    # Column header
    printf "${BOLD}  %-28s  %6s  %s${RESET}\n" "Type" "Count" "Bar"
    printf "${CYAN}  %s${RESET}\n" "$(printf '%.0s--' {1..58})"

    local max_count=1
    for key in "${TYPE_KEYS[@]}"; do
        [[ ${TYPE_COUNT[$key]} -gt $max_count ]] && max_count=${TYPE_COUNT[$key]}
    done

    for key in "${TYPE_KEYS[@]}"; do
        local count=${TYPE_COUNT[$key]}
        [[ $count -eq 0 ]] && continue

        local label="${TYPE_LABEL[$key]}"

        # Colour coding per category
        local col="$RESET"
        case $key in
            ELF|PE_EXE|JAVA_CLASS|DEX)               col="$RED"     ;;
            APK_APKX)                                col="$GREEN"   ;;
            BASH_SHELL|PYTHON|POWERSHELL|RUBY|PERL)  col="$YELLOW"  ;;
            PCAP|PCAPNG)                             col="$MAGENTA" ;;
            ZIP|GZIP|TAR|7ZIP|RAR)                   col="$CYAN"    ;;
            OTHER)                                   col="$DIM"     ;;
        esac

        # Bar chart (max 30 chars wide)
        local bar_len=$(( count * 30 / max_count ))
        [[ $bar_len -lt 1 && $count -gt 0 ]] && bar_len=1
        local bar
        bar=$(printf '█%.0s' $(seq 1 $bar_len))

        printf "  ${col}%-28s${RESET}  ${BOLD}%6d${RESET}  ${col}%s${RESET}\n" \
               "$label" "$count" "$bar"

        if $LIST_FILES && [[ -n "${TYPE_FILES[$key]}" ]]; then
            printf "${DIM}%b${RESET}" "${TYPE_FILES[$key]}"
        fi
    done

    printf "${BOLD}${CYAN}%s${RESET}\n" "$line"
    printf "  ${BOLD}%-28s  %6d${RESET}\n" "TOTAL" "$TOTAL"
    printf "${BOLD}${CYAN}%s${RESET}\n" "$line"
}

main() {
    while getopts ":rlo:ch" opt; do
        case $opt in
            r) RECURSE=true ;;
            l) LIST_FILES=true ;;
            o) OUTPUT_FILE="$OPTARG" ;;
            c) USE_COLOR=false ;;
            h) usage ;;
            :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
            *) echo "Unknown option: -$OPTARG" >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 [-r] [-l] [-c] [-o report.txt] <directory>"
        exit 1
    fi

    SCAN_DIR="${1%/}"

    if [[ ! -d "$SCAN_DIR" ]]; then
        echo "Error: '$SCAN_DIR' is not a directory." >&2
        exit 1
    fi

    setup_colors
    check_deps

    echo -e "${DIM}Scanning files…${RESET}"
    scan

    if [[ -n "$OUTPUT_FILE" ]]; then
        # Save plain-text copy (strip ANSI)
        print_report | sed 's/\x1b\[[0-9;]*m//g' > "$OUTPUT_FILE"
        echo -e "${GREEN}Report saved to: $OUTPUT_FILE${RESET}"
    fi

    print_report
}

main "$@"