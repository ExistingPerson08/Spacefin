#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "\n${CYAN}======================================================"
echo -e "                   Spacefin Update"
echo -e "======================================================${NC}"

run_update() {
    local TOOL_NAME=$1
    local COMMAND=$2

    echo -e "\n${BLUE}>>> STARTING: $TOOL_NAME Update...${NC}"

    # Check if the tool is available
    if command -v $TOOL_NAME &> /dev/null; then
        echo -e "${YELLOW}> Executing: $COMMAND${NC}"
        echo ""

        # Execute the command, redirecting output for cleaner logging
        if eval "$COMMAND"; then
            echo -e "${GREEN}> SUCCESS: $TOOL_NAME updated successfully!${NC}"
            echo ""
        else
            echo -e "${RED}> ERROR: $TOOL_NAME update FAILED. Check the messages above.${NC}"
            echo ""
        fi
    else
        echo -e "${YELLOW}> WARNING: Tool '$TOOL_NAME' not found. Skipping...${NC}"
        echo ""
    fi
}

# Variable to track if a reboot is needed
REBOOT_NEEDED=0

# ---------------------------------------------------------------------

# 1. Bootc Update
run_update "bootc" "sudo LC_ALL=C.UTF-8 bootc upgrade"

# Check if we need to reboot
if command -v bootc &> /dev/null; then
    if sudo bootc status --json | grep -q '"staged"'; then
        REBOOT_NEEDED=1
    fi
fi

# ---------------------------------------------------------------------

# 2. FLATPAK Update
run_update "flatpak" "flatpak update --noninteractive"

# ---------------------------------------------------------------------

# 3. HOMEBREW (brew) Update
# Brew requires to update itself first ('brew update') and then packages ('brew upgrade')
run_update "brew" "brew update && brew upgrade"

# ---------------------------------------------------------------------

# Conclusion and Reboot Notification (Moved to the end)
echo -e "\n${CYAN}======================================================"
echo -e "             ALL UPDATES COMPLETED"
echo -e "======================================================${NC}"

if [ $REBOOT_NEEDED -eq 1 ]; then
    echo -e "\n${RED}*** REBOOT REQUIRED ***"
    echo -e "${YELLOW}The system update was successful and a new deployment is staged."
    echo -e "Please RESTART your system to boot into the new version.${NC}\n"
else
    echo -e ""
fi

exit 0
