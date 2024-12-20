#!/bin/bash

# RPC URLa (public or private)
declare -A networks
networks=(
    ["Arbitrum Sepolia"]="https://sepolia-rollup.arbitrum.io/rpc"
    ["Base Sepolia"]="https://sepolia.base.org"
    ["Blast Sepolia"]="https://sepolia.blast.io"
    ["Optimism Sepolia"]="https://sepolia.optimism.io"
)

# Wallet adrese
wallets=(
    "0xwallet1"
    "0xwallet2"
)

# Get ETH balance function
get_eth_balance() {
    local rpc_url=$1
    local wallet_address=$2

    # JSON-RPC request
    local data=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "method": "eth_getBalance",
    "params": ["$wallet_address", "latest"],
    "id": 1
}
EOF
    )

    # Send request and fetch results
    local response=$(curl -s -X POST -H "Content-Type: application/json" --data "$data" "$rpc_url")
    local balance_hex=$(echo "$response" | jq -r '.result')

    if [[ -z "$balance_hex" || "$balance_hex" == "null" ]]; then
        echo "Error"
        return
    fi

    # Convert hex into decimal number (Wei -> ETH)
    # Use `printf` to properly convert large hex values to decimal
    local balance_dec=$(printf "%d\n" "$balance_hex" 2>/dev/null || echo "Error")
    if [[ "$balance_dec" == "Error" ]]; then
        echo "Error"
        return
    fi

    # Convert Wei to ETH
    local balance_eth=$(echo "scale=18; $balance_dec / 1000000000000000000" | bc)
    echo "$balance_eth"
}

# Format the table
printf "%-44s %-20s %-15s\n" "Wallet" "Network" "ETH Balance"
printf "%s\n" "------------------------------------------------------------------------------------------"

for wallet in "${wallets[@]}"; do
    for network in "${!networks[@]}"; do
        rpc_url=${networks[$network]}
        balance=$(get_eth_balance "$rpc_url" "$wallet")
        if [[ "$balance" == "Error" ]]; then
            printf "%-44s %-20s %-15s\n" "$wallet" "$network" "Error"
        else
            printf "%-44s %-20s %-15s\n" "$wallet" "$network" "$balance ETH"
        fi
    done
    printf "%s\n" "------------------------------------------------------------------------------------------"
done
