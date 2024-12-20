#!/bin/bash

# RPC URLs for networks
declare -A networks
# These are public RPCs. You can put here your private RPCs (ie. Alchemy)
networks=(
    ["Arbitrum Sepolia"]="https://arbitrum-sepolia-rpc.publicnode.com"
    ["Base Sepolia"]="https://sepolia.base.org"
    ["Blast Sepolia"]="https://sepolia.blast.io"
    ["Optimism Sepolia"]="https://sepolia.optimism.io"
)

# Wallet adresses
wallets=(
    "0xwallet1"
    "0xwallet2"
)

# Function to fetch ETH balance
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
    else
        # Convert hex into decimal number (Wei -> ETH)
        balance_dec=$(printf "%d" "$balance_hex")
        echo "scale=18; $balance_dec / 1000000000000000000" | bc
    fi
}

# Format the table
printf "%-44s %-20s %-15s\n" "Wallet" "Network" "ETH Balance"
printf "%s\n" "------------------------------------------------------------------------------------------"

for wallet in "${wallets[@]}"; do
    for network in "${!networks[@]}"; do
        rpc_url=${networks[$network]}
        balance=$(get_eth_balance "$rpc_url" "$wallet")
        printf "%-44s %-20s %-15s\n" "$wallet" "$network" "$balance ETH"
    done
    printf "%s\n" "------------------------------------------------------------------------------------------"
done
