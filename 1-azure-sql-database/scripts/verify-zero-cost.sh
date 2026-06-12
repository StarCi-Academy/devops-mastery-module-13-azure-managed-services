#!/usr/bin/env bash
# verify-zero-cost.sh — after `terraform destroy`, assert no resource is left
# behind still billing. An Azure SQL database bills continuously while it exists
# (DTU/vCore + storage), and a failover group keeps a billed replica on the
# secondary server, so an orphaned database is a classic cost leak. On Azure the
# simplest guarantee is that the whole Resource Group is gone (deleting the RG
# deletes every child: both SQL servers, the database and the failover group).
# Run with the resource group name as the first arg.
set -euo pipefail

RG_NAME="${1:-starci-sql-lab-rg}"
: "${ARM_SUBSCRIPTION_ID:?ARM_SUBSCRIPTION_ID env var required (the Azure subscription ID)}"

echo "[verify] checking resource group ${RG_NAME} no longer exists in ${ARM_SUBSCRIPTION_ID}..."

EXISTS=$(az group exists --name "${RG_NAME}" --subscription "${ARM_SUBSCRIPTION_ID}")

if [ "${EXISTS}" = "false" ]; then
  echo "OK: resource group ${RG_NAME} is gone — zero residual cost (no orphaned SQL database/server)."
  exit 0
else
  echo "WARN: resource group ${RG_NAME} still exists — SQL database/servers may still bill:"
  az resource list --resource-group "${RG_NAME}" \
    --subscription "${ARM_SUBSCRIPTION_ID}" \
    --output table
  exit 1
fi
