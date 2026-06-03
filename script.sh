#!/bin/bash

if [ -z "$BASH_VERSION" ]; then
    echo "How the fuck do you not have bash installed. HOW???"
    exit 1
fi

# When run via curl | bash, stdin is the pipe not the terminal.
[[ ! -t 0 ]] && exec < /dev/tty

# ---------------- CONFIG ----------------

quotes=(
    "100% skidded"
    "furrychrome."
    "carbonbreaker!"
    "buzzword buzzword,"
    "please STOP!"
    "lol."
    "odd numbers suck"
    "hey that hurts! :("
    "unique text here"
    "son im crine"
    "modmium coming never"
    "modmium coming NOW"
    "battery_cutoff_request=1"
    "spooky scary didybluds"
    "unenrollment speedrun."
    "skid skid skid sahur"
    "mmm chezburger"
    "500 cigarettes"
    "i use pujjo btw."
    "speed kills a fan."
    "still thinking"
    "terminal magic"
    "saub my daub"
    "check out Nikki-VT2!"
    "gubby this, gubby that"
    "gubby server gubby lan"
    "Nothing There!"
    "HAPPY BDAY DANIEL!"
    "aura monster"
    "bin/bash"
    "quicksilver!"
    "sh1mmer!"
    "protowrite!!"
    "br0ker!!"
    "quote."
    "can you ctrl+c already"
)

quote="${quotes[RANDOM % ${#quotes[@]}]}"

# ---------------- HELPERS ----------------

center() {
    local text="$1"
    local width="$2"
    if (( ${#text} > width )); then
        text="${text:0:width}"
    fi
    local pad_left=$(( (width - ${#text}) / 2 ))
    local pad_right=$(( width - ${#text} - pad_left ))
    printf "%*s%s%*s" "$pad_left" "" "$text" "$pad_right" ""
}

info_row() {
    local label="$1"
    local value="$2"
    local inner_w="$3"
    local label_w="$4"
    local value_w=$(( inner_w - label_w - 3 ))
    if (( ${#value} > value_w )); then
        value="${value:0:value_w}"
    fi
    printf "│ %-${label_w}s %${value_w}s │\n" "$label" "$value"
}

# Wrapper: prompt then read from /dev/tty, skip empty
tty_read() {
    local prompt="$1"
    local varname="$2"
    local val=""
    echo -n "$prompt"
    exec 3< /dev/tty
    while IFS= read -r val <&3; do
        [[ -n "$val" ]] && break
    done
    exec 3<&-
    printf -v "$varname" '%s' "$val"
}

# Read any key (including empty/enter) from /dev/tty — for "press enter to continue"
tty_anykey() {
    local msg="${1:-Press enter to continue...}"
    echo "$msg"
    read -r _ < /dev/tty
}

# ---------------- HEADER ----------------

draw_header() {
    local left="Simple AIO Script"
    local right="v1.0.1"
    local by="by wato"

    echo "┌─────────────────────┬──────┐"
    printf "│%s│%s│\n" "$(center "$left" 21)" "$right"
    printf "│%s├──────┤\n" "$(center "$by" 21)"
}

# ---------------- ENROLLMENT MENU ----------------

menu_enrollment() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│      Enrollment options      │"
        echo "├──────────────────────────────┤"
        echo "│ (q) Temp-unenroll in devmode │"
        echo "│ (w) Launch Cr3nroll          │"
        echo "│ (e) Back                     │"
        echo "└──────────────────────────────┘"

        tty_read "Select an option: " e_choice

        case "$e_choice" in
            q)
                tty_read "Are you sure? (y/n): " confirm
                case "$confirm" in
                    y|Y)
                        mount --bind /dev/null /tmp/machine-info
                        initctl restart ui
                        echo "Success!"
                        tty_anykey "Press enter to go back..."
                        ;;
                    *)
                        echo "Cancelled."
                        tty_anykey "Press enter to go back..."
                        ;;
                esac
                ;;
            w)
                clear
                curl -fsSL "https://raw.githubusercontent.com/CrOSmium/Cr3nroll/refs/heads/main/cr3nroll.sh" -o /tmp/cr3nroll.sh && sudo bash /tmp/cr3nroll.sh
                ;;
            e)
                break
                ;;
            *)
                echo "Invalid option."
                tty_anykey
                ;;
        esac
    done
}

# ---------------- FIRMWARE MENU ----------------

menu_firmware() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│       Firmware options       │"
        echo "├──────────────────────────────┤"
        echo "│ (q) GBB Bash-inator          │"
        echo "│ (w) MrChromebox Utility      │"
        echo "│ (e) WP + GBB Information     │"
        echo "│ (r) Back                     │"
        echo "└──────────────────────────────┘"

        tty_read "Select an option: " f_choice

        case "$f_choice" in
            q)
                clear
                curl -fsSL "https://raw.githubusercontent.com/watodoto/aio/refs/heads/main/gbb.sh" -o /tmp/gbb.sh && bash /tmp/gbb.sh
                ;;
            w)
                clear
                curl -fsSL "https://mrchromebox.tech/firmware-util.sh" -o /tmp/firmware-util.sh && sudo bash /tmp/firmware-util.sh
                ;;
            e)
                clear
                curl -fsSL "https://raw.githubusercontent.com/watodoto/aio/refs/heads/main/wp.sh" -o /tmp/wp.sh && sudo bash /tmp/wp.sh
                ;;
        esac
    done
}

# ---------------- WIFI MENU (stub) ----------------

menu_wifi() {
    while true; do
        clear

        echo "┌────────────────── ────────────┐"
        echo "│         Wi-Fi options         │"
        echo "├──────────────────────── ──────┤"
        echo "│ (q) Coming soon...            │"
        echo "│ (w) Back                      │"
        echo "└───────────────────── ─────────┘"

        tty_read "Select an option: " w_choice

        case "$w_choice" in
            w)
                break
                ;;
            *)
                echo "Invalid option."
                tty_anykey
                ;;
        esac
    done
}

# ---------------- MISC MENU (stub) ----------------

menu_misc() {
    while true; do
        clear

        echo "┌──────────────────────────────┐"
        echo "│      Miscellaneous options   │"
        echo "├──────────────────────────────┤"
        echo "│ (q) Coming soon...           │"
        echo "│ (w) Back                     │"
        echo "└──────────────────────────────┘"

        tty_read "Select an option: " m_choice

        case "$m_choice" in
            w)
                break
                ;;
            *)
                echo "Invalid option."
                tty_anykey
                ;;
        esac
    done
}

# ---------------- MAIN MENU ----------------

draw_menu() {
    clear

    draw_header

    echo "├────────────────────────────┤"
    printf "│%s│\n" "$(center "\"$quote\"" 28)"
    echo "├────────────────────────────┤"
    echo "│ (q) Enrollment             │"
    echo "│ (w) Firmware               │"
    echo "│ (e) Wi-Fi                  │"
    echo "│ (r) Miscellaneous          │"
    echo "│ (t) Exit                   │"
    echo "└────────────────────────────┘"
}

# ---------------- MAIN LOOP ----------------

while true; do
    draw_menu

    tty_read "Select an option: " choice

    case "$choice" in
        q) menu_enrollment ;;
        w) menu_firmware   ;;
        e) menu_wifi       ;;
        r) menu_misc       ;;
        t)
            clear
            exit 0
            ;;
        *)
            echo "Invalid option."
            tty_anykey
            ;;
    esac
done
