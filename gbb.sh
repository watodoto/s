#!/bin/bash

# ---------------- DATA CONFIG ----------------
gbb_names=(
    "DEV_SCREEN_SHORT_DELAY"
    "LOAD_OPTION_ROMS"
    "ENABLE_ALTERNATE_OS"
    "FORCE_DEV_SWITCH_ON"
    "FORCE_DEV_BOOT_USB"
    "DISABLE_FW_ROLLBACK_CHECK"
    "ENTER_TRIGGERS_TONORM"
    "FORCE_DEV_BOOT_ALTFW"
    "DEPRECATED_RUNNING_FAFT"
    "DISABLE_EC_SOFTWARE_SYNC"
    "DEFAULT_DEV_BOOT_ALTFW"
    "DISABLE_AUXFW_SOFTWARE_SYNC"
    "DISABLE_LID_SHUTDOWN"
    "FORCE_UNLOCK_FASTBOOT"
    "FORCE_MANUAL_RECOVERY"
    "DISABLE_FWMP"
    "ENABLE_UDC"
    "FORCE_CSE_SYNC"
)

gbb_descs=(
    "Reduce the dev screen delay to 2 sec from 30 sec. Beep is also removed."
    "[Unsupported] BIOS should load option ROMs from arbitrary PCI devices."
    "[Unsupported] Boot a non-ChromeOS kernel."
    "Force dev switch on, regardless of physical/keyboard dev switch. Be careful; this does not bypass FWMP."
    "Allow booting from external disk even if dev_boot_usb=0."
    "Disable firmware rollback protection."
    "Allow Enter key to trigger dev->tonorm screen transition."
    "Allow booting altfw OSes even if dev_boot_altfw=0."
    "[Deprecated] Currently running FAFT tests. Should not normally be set."
    "Disable EC software sync."
    "Default to booting altfw OS when dev screen times out."
    "Disable auxiliary firmware (auxfw) software sync."
    "Disable shutdown on lid closed."
    "Allow full fastboot capability even in verified mode, and regardless of OEM lock."
    "Recovery mode always assumes manual recovery, even if EC_IN_RW=1."
    "Ignore FWMP."
    "Enable USB Device Controller."
    "Always sync CSE, even if it is same as CBFS CSE."
)

# ---------------- STATE ----------------
gbb_states=()
for ((i=0; i<${#gbb_names[@]}; i++)); do
    gbb_states+=(0)
done

total_flags=${#gbb_names[@]}
current_index=0

# ---------------- BITWISE ----------------
calc_gbb_hex() {
    local hex_val=0
    for i in "${!gbb_names[@]}"; do
        [[ "${gbb_states[$i]}" == "1" ]] && (( hex_val |= (1 << i) ))
    done
    printf "0x%X" "$hex_val"
}

decode_gbb_hex() {
    local input_val="${1#0x}"
    [[ -z "$input_val" ]] && return

    local dec_val=$((16#$input_val))
    for i in "${!gbb_names[@]}"; do
        if (( dec_val & (1 << i) )); then
            gbb_states[$i]=1
        else
            gbb_states[$i]=0
        fi
    done
}

# ---------------- INPUT ----------------
read_key() {
    local key seq
    read -rsn1 key
    if [[ "$key" == $'\e' ]]; then
        read -rsn2 -t 0.1 seq
        key="$key$seq"
    fi
    INPUT_KEY="$key"
}

# ---------------- RENDER (FIXED ENGINE) ----------------
draw_interface() {

    # IMPORTANT: move to top WITHOUT full flicker clear
    printf "\e[H"

    # ALWAYS hide cursor (VT2-safe)
    printf "\e[?25l"

    local current_hex
    current_hex=$(calc_gbb_hex)

    mapfile -t desc_lines < <(
        printf "%s\n" "${gbb_descs[$current_index]}" | fold -s -w 49
    )

    # ---------------- TOP ----------------
    printf "┌───────────────────────────────────┬───────────────────────────────────────────────────┐\n"
    printf "│      GBB-flaginator in Bash!      │ Press enter to select, Use arrows to navigate.    │\n"
    printf "├───────────────────────────────────┤ Press E to exit the tool!                         │\n"

    # ---------------- LIST ----------------
    for i in "${!gbb_names[@]}"; do
        local marker=" "
        [[ $i -eq $current_index ]] && marker=">"

        local box="[ ]"
        [[ "${gbb_states[$i]}" == "1" ]] && box="[x]"

        local left_content
        left_content=$(printf "%s %s %-27s" "$marker" "$box" "${gbb_names[$i]}")

        local right_content=""
        local sep=0

        case "$i" in
            0) right_content=" Press D to decode flags.                          │" ;;
            1) right_content="───────────────────────────────────────────────────┤" ; sep=1 ;;
            2) right_content=$(printf " Flags: %-42s │" "$current_hex") ;;
            3) right_content="───────────────────────────────────────────────────┤" ; sep=1 ;;
            4) right_content=$(printf " %-49s │" "${gbb_names[$current_index]:0:49}") ;;
            5) right_content=$(printf " %-49s │" "${desc_lines[0]:-}") ;;
            6) right_content=$(printf " %-49s │" "${desc_lines[1]:-}") ;;
            7) right_content=$(printf " %-49s │" "${desc_lines[2]:-}") ;;
            8) right_content="───────────────────────────────────────────────────┘" ; sep=1 ;;
            *) right_content="" ;;
        esac

        # FIX 1: full overwrite + padding prevents ghost text
        printf "\e[2K\r"

        if (( i <= 8 )); then
            if (( sep )); then
                printf "│ %-33s ├%-51s│\n" "$left_content" "$right_content"
            else
                printf "│ %-33s │%-51s│\n" "$left_content" "$right_content"
            fi
        else
            printf "│ %-33s │%-51s│\n" "$left_content" "$right_content"
        fi
    done

    # ---------------- FIX 2: VT2 GHOST ROW CLEANUP ----------------
    # clears leftover line under UI safely without breaking border
    printf "\e[2K\r"
    printf "\e[?25l"
}

# ---------------- CLEANUP ----------------
cleanup() {
    printf "\e[?25h\e[0m"
    clear
    exit 0
}
trap cleanup SIGINT SIGTERM

# ---------------- START ----------------
clear
printf "\e[?25l"

while true; do
    draw_interface
    read_key

    case "$INPUT_KEY" in
        s|S|$'\e[B')
            (( current_index < total_flags - 1 )) && (( current_index++ ))
            ;;
        w|W|$'\e[A')
            (( current_index > 0 )) && (( current_index-- ))
            ;;
        $'\n'|$'\r'|"")
            (( gbb_states[current_index] ^= 1 ))
            ;;
        d|D)
            printf "\e[?25h"
            printf "\n➔ Enter hex string (e.g., 0x18019): "
            read -r user_input
            if [[ "$user_input" =~ ^(0x)?[0-9a-fA-F]+$ ]]; then
                decode_gbb_hex "$user_input"
            fi
            printf "\e[?25l"
            printf "\e[H\e[J"
            ;;
        e|E)
            cleanup
            ;;
    esac
done
