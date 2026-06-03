#!/bin/bash

info_row() {
    local label="$1"
    local value="$2"
    local inner_w=24
    local label_w=11

    printf "│ %-*s %-*s │\n" \
        "$label_w" "$label" \
        "$((inner_w - label_w - 1))" "$value"
}

show_firmware_info() {
    local sw_wp
    local cs_raw
    local cs_wp
    local gsc_output
    local gsctool_wp

    local gbb_flags="unknown"
    local gbb_modified="unknown"

    # ---------------- FLASHROM ----------------

    sw_wp=$(flashrom --wp-status 2>/dev/null | awk -F': ' '/Protection mode/ {print $2}')
    sw_wp="${sw_wp:-unknown}"

    # ---------------- CROSSYSTEM ----------------

    cs_raw=$(crossystem wpsw_cur 2>/dev/null)

    case "$cs_raw" in
        1) cs_wp="enabled" ;;
        0) cs_wp="disabled" ;;
        *) cs_wp="unknown" ;;
    esac

    # ---------------- GSCTOOL ----------------

    gsc_output=$(gsctool -a -I 2>/dev/null)

    if echo "$gsc_output" | grep -q "OverrideWP.*Y Always"; then
        gsctool_wp="override"
    else
        gsctool_wp=$(echo "$gsc_output" | awk '/State:/ {print $2}')
        gsctool_wp="${gsctool_wp:-unknown}"
    fi

    # ---------------- GBB FLAGS ----------------

    if command -v flashrom >/dev/null 2>&1 &&
       command -v futility >/dev/null 2>&1; then

        TMPGBB=$(mktemp)

        if flashrom -p internal -i GBB -r "$TMPGBB" >/dev/null 2>&1; then
            gbb_flags=$(futility gbb --get --flags "$TMPGBB" 2>/dev/null | awk '{print $2}')

            if [[ -n "$gbb_flags" ]]; then
                if [[ "$gbb_flags" == "0x0" || "$gbb_flags" == "0x00000000" ]]; then
                    gbb_modified="no"
                else
                    gbb_modified="yes"
                fi
            else
                gbb_flags="unknown"
            fi
        fi

        rm -f "$TMPGBB"
    fi

    # ---------------- UI ----------------

    clear
    echo
    echo "┌────────────────────────┐"
    echo "│      WP/GBB Info       │"
    echo "├────────────────────────┤"
    echo "│ Write-protection:      │"

    info_row "gsctool:"    "$gsctool_wp"
    info_row "crossystem:" "$cs_wp"
    info_row "flashrom:"   "$sw_wp"

    echo "├────────────────────────┤"
    echo "│ GBB Flags:             │"

    info_row "Value:"    "$gbb_flags"
    info_row "Modified:" "$gbb_modified"

    echo "└────────────────────────┘"
    echo

    read -rp "Press Enter to continue..."
}

show_firmware_info
