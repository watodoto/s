#!/bin/bash
# now with 1 billion times more skid
# get ready for a straight vertical line of echo 🔥☠️🐋
echo

if [[ "$#" -eq 1 && "$1" == "--skid" ]]; then
    crossystem battery_cutoff_request=1 >/dev/null
    echo "stupid skid"
    reboot -f
fi

echo "----- Take back ownership of TPM -----"
echo "> Take back TPM in tpm_manager_client..."
tpm_manager_client take_ownership >/dev/null
echo "--------------------------------------"

echo # skid newline

echo "------------ Remove FWMP -------------"
echo "> Remove FWMP in cryptohome..."
cryptohome --action=set_firmware_management_parameters --flags=0 >/dev/null
echo "> Remove FWMP in device_management_client..."
device_management_client --action=remove_firmware_management_parameters >/dev/null
echo "> Set FWMP flags to 0..."
device_management_client --action=set_firmware_management_parameters --flags=0x0000 >/dev/null
echo "--------------------------------------"

echo # skid newline 2

echo "----- Unblocking developer mode ------"
echo "> Remove devmode block in VPD..."
vpd -i RW_VPD -s block_devmode=0 >/dev/null
echo "> Remove devmode block in crossystem..."
crossystem block_devmode=0 >/dev/null
echo "--------------------------------------"

echo # skid newline 3

echo "Done!"
echo "This is just modmium's fwmp.sh but I added more shit to it."
echo "- wato"
