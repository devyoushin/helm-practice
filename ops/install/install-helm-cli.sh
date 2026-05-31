#!/usr/bin/env bash
set -euo pipefail

HELM_VERSION="${HELM_VERSION:-v3.17.0}"
OS="$(uname | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "${ARCH}" in
  x86_64) ARCH="amd64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-${OS}-${ARCH}.tar.gz" \
  -o "${tmpdir}/helm.tgz"
tar -xzf "${tmpdir}/helm.tgz" -C "${tmpdir}"
sudo install -m 0755 "${tmpdir}/${OS}-${ARCH}/helm" /usr/local/bin/helm

helm version
