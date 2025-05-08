#!/bin/bash

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display header
print_header() {
    clear
    echo -e "${GREEN}=== System Process Monitor ===${NC}"
    echo -e "${YELLOW}Press 'q' to quit, 'k' to kill a process${NC}"
    echo
}

# Function to kill a process
kill_process() {
    echo -e "${YELLOW}Enter PID to kill: ${NC}"
    read pid
    if Get-Process -Id $pid -ErrorAction SilentlyContinue; then
        echo -e "${YELLOW}Are you sure you want to kill process $pid? (y/n)${NC}"
        read confirm
        if [ "$confirm" = "y" ]; then
            Stop-Process -Id $pid -Force
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Process $pid killed successfully${NC}"
            else
                echo -e "${RED}Failed to kill process $pid${NC}"
            fi
        fi
    else
        echo -e "${RED}Process $pid does not exist${NC}"
    fi
    sleep 2
}

# Main loop
while true; do
    print_header
    
    # Display top processes sorted by CPU usage
    echo -e "${GREEN}Top CPU-consuming processes:${NC}"
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table -Property Id, ProcessName, CPU, WorkingSet
    
    echo -e "\n${GREEN}Top memory-consuming processes:${NC}"
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 | Format-Table -Property Id, ProcessName, CPU, WorkingSet
    
    # Read user input with timeout
    read -t 2 -n 1 input
    case $input in
        q|Q) 
            echo -e "\n${GREEN}Exiting...${NC}"
            exit 0
            ;;
        k|K)
            kill_process
            ;;
    esac
done 