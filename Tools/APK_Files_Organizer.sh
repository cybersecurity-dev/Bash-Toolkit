#!/usr/bin/env bash
# ==================================================================================================================================================
#  ./APK_Files_Organizer.sh <source_dir> <destination_dir>
#  ./APK_Files_Organizer.sh -r -v <source_dir> <destination_dir>
#  ./APK_Files_Organizer.sh -d <source_dir> <destination_dir>   # dry-run
# ==================================================================================================================================================

set -euo pipefail

# ---- Colours ------------------------------------------------------------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---- Defaults ------------------------------------------------------------------------------------------------------------------------------------
RECURSE=false
DRY_RUN=false
VERBOSE=false
MOVED=0
SKIPPED=0
ERRORS=0

# ---- APK / APKX magic number ------------------------------------------------------------------------------------------------------
# Both formats are ZIP archives: first 4 bytes = 50 4B 03 04 (PK\x03\x04)
APK_MAGIC="504b0304"

usage() {
    sed -n '2,12p' "$0" | sed 's/^# \{0,3\}//'
    echo ""
    echo -e "${BOLD}Options:${RESET}"
    echo "  -r   Recurse into sub-directories"
    echo "  -d   Dry-run (print what would be moved, but don't move anything)"
    echo "  -v   Verbose output"
    echo "  -h   Show this help message"
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo "  ./move_apk_files.sh /downloads /apks"
    echo "  ./move_apk_files.sh -r -v /downloads /apks"
    echo "  ./move_apk_files.sh -d /downloads /apks   # dry-run"
    exit 0
}

# ---- Parse options --------------------------------------------------------------------------------------------------------------------------
while getopts ":rdvh" opt; do
    case $opt in
        r) RECURSE=true ;;
        d) DRY_RUN=true ;;
        v) VERBOSE=true ;;
        h) usage ;;
        *) echo -e "${RED}Unknown option: -$OPTARG${RESET}" >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# ---- Validate positional arguments ------------------------------------------------------------------------------------------
if [[ $# -lt 2 ]]; then
    echo -e "${RED}Error: source and destination directories are required.${RESET}"
    echo "Usage: $0 [-r] [-d] [-v] <source_dir> <dest_dir>"
    exit 1
fi

SRC_DIR="${1%/}"   # strip trailing slash
DEST_DIR="${2%/}"

if [[ ! -d "$SRC_DIR" ]]; then
    echo -e "${RED}Error: source directory '$SRC_DIR' does not exist.${RESET}"
    exit 1
fi

# ---- Create destination directory if needed ------------------------------------------------------------------------
if [[ ! -d "$DEST_DIR" ]]; then
    echo -e "${YELLOW}Destination '$DEST_DIR' does not exist — creating it.${RESET}"
    if ! $DRY_RUN; then
        mkdir -p "$DEST_DIR"
    fi
fi

# ---- Dependency check --------------------------------------------------------------------------------------------------------------------
for cmd in xxd find mv; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}Error: required command '$cmd' not found.${RESET}"
        exit 1
    fi
done

# ---- Magic-number check ----------------------------------------------------------------------------------------------------------------
# Returns 0 (true) if the file starts with the APK/ZIP magic bytes
is_apk_by_magic() {
    local file="$1"
    local magic
    # Read first 4 bytes, convert to lowercase hex, strip spaces
    magic=$(xxd -p -l 4 "$file" 2>/dev/null | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    [[ "$magic" == "$APK_MAGIC" ]]
}

# ---- Process a single file ----------------------------------------------------------------------------------------------------------
process_file() {
    local file="$1"

    # Skip if not a regular file or not readable
    if [[ ! -f "$file" || ! -r "$file" ]]; then
        $VERBOSE && echo -e "${YELLOW}  SKIP (not readable): $file${RESET}"
        ((SKIPPED++)) || true
        return
    fi

    if is_apk_by_magic "$file"; then
        local filename
        filename=$(basename "$file")
        local dest_path="$DEST_DIR/$filename"

        # Handle filename collisions
        if [[ -e "$dest_path" ]]; then
            local base="${filename%.*}"
            local ext="${filename##*.}"
            dest_path="$DEST_DIR/${base}_$(date +%s%N).${ext}"
            echo -e "${YELLOW}  Collision — renaming to: $(basename "$dest_path")${RESET}"
        fi

        if $DRY_RUN; then
            echo -e "${CYAN}  [DRY-RUN] Would move: $file${RESET}"
            echo -e "${CYAN}            → $dest_path${RESET}"
        else
            if mv -- "$file" "$dest_path"; then
                echo -e "${GREEN}  ✔ Moved: $file${RESET}"
                $VERBOSE && echo -e "          → $dest_path"
                ((MOVED++)) || true
            else
                echo -e "${RED}  ✘ Error moving: $file${RESET}" >&2
                ((ERRORS++)) || true
            fi
        fi
        $DRY_RUN && ((MOVED++)) || true
    else
        $VERBOSE && echo -e "  SKIP (no APK magic): $file"
        ((SKIPPED++)) || true
    fi
}

# ---- Scan --------------------------------------------------------------------------------------------------------------------------------------------
echo -e "${BOLD}=======================================================================================================================================${RESET}"
echo -e "${BOLD} APK / APKX Magic-Number File Mover${RESET}"
echo -e "${BOLD}=======================================================================================================================================${RESET}"
echo -e " Source : ${CYAN}$SRC_DIR${RESET}"
echo -e " Dest   : ${CYAN}$DEST_DIR${RESET}"
echo -e " Recurse: $RECURSE | Dry-run: $DRY_RUN | Verbose: $VERBOSE"
echo -e "${BOLD}----------------------------------------${RESET}"

$DRY_RUN && echo -e "${YELLOW}[DRY-RUN MODE — no files will be moved]${RESET}\n"

if $RECURSE; then
    # -maxdepth is omitted so find descends fully
    while IFS= read -r -d '' file; do
        process_file "$file"
    done < <(find "$SRC_DIR" -type f -print0)
else
    # Only immediate children of SRC_DIR
    while IFS= read -r -d '' file; do
        process_file "$file"
    done < <(find "$SRC_DIR" -maxdepth 1 -type f -print0)
fi

# ---- Summary --------------------------------------------------------------------------------------------------------------------------------------
echo -e "${BOLD}----------------------------------------${RESET}"
echo -e " ${GREEN}Moved  : $MOVED${RESET}"
echo -e " ${YELLOW}Skipped: $SKIPPED${RESET}"
echo -e " ${RED}Errors : $ERRORS${RESET}"
echo -e "${BOLD}=======================================================================================================================================${RESET}"

[[ $ERRORS -eq 0 ]] && exit 0 || exit 1