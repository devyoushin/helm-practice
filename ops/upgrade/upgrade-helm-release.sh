#!/usr/bin/env bash
set -euo pipefail

RELEASE="${RELEASE:?set RELEASE}"
CHART="${CHART:?set CHART}"
NAMESPACE="${NAMESPACE:-default}"
VALUES_FILE="${VALUES_FILE:-values.yaml}"

helm diff upgrade "${RELEASE}" "${CHART}" \
  --namespace "${NAMESPACE}" \
  --values "${VALUES_FILE}" || true

helm upgrade --install "${RELEASE}" "${CHART}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --values "${VALUES_FILE}" \
  --atomic \
  --timeout 10m

helm status "${RELEASE}" -n "${NAMESPACE}"
helm history "${RELEASE}" -n "${NAMESPACE}"
