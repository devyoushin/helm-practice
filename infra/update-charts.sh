#!/usr/bin/env bash
# update-charts.sh
# 목적: upstream Helm 차트를 각 base/ 디렉토리에 vendoring
#
# 사용법:
#   ./update-charts.sh               # 전체 차트 업데이트
#   ./update-charts.sh karpenter     # 특정 차트만 업데이트
#
# 버전 변경: 이 파일에서 VERSION 변수만 수정 후 재실행
# 주의: base/ 디렉토리는 절대 수동으로 편집하지 않음

set -euo pipefail

CHARTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── 버전 정의 ──────────────────────────────────────────────────
KARPENTER_VERSION="1.1.1"
CERT_MANAGER_VERSION="1.16.2"
KUBE_PROMETHEUS_STACK_VERSION="66.3.1"

# ── 함수 ──────────────────────────────────────────────────────
pull_chart() {
  local name="$1"
  local repo="$2"
  local version="$3"
  local dest="$4"

  echo ""
  echo "==> Pulling ${name} ${version}..."

  # 기존 base 삭제
  rm -rf "${dest}/base"
  mkdir -p "${dest}"

  # OCI 레지스트리와 일반 레포 구분
  if [[ "${repo}" == oci://* ]]; then
    helm pull "${repo}" \
      --version "${version}" \
      --untar \
      --untardir "${dest}/base_tmp"
    # helm pull --untar 시 차트 이름으로 서브디렉토리 생성됨
    mv "${dest}/base_tmp/${name}" "${dest}/base"
    rmdir "${dest}/base_tmp"
  else
    helm pull "${repo}/${name}" \
      --version "${version}" \
      --untar \
      --untardir "${dest}/base_tmp"
    mv "${dest}/base_tmp/${name}" "${dest}/base"
    rmdir "${dest}/base_tmp"
  fi

  echo "    저장 완료: ${dest}/base"
  echo "    Chart.yaml: $(grep '^version:' "${dest}/base/Chart.yaml")"
}

# ── 레포 추가 ─────────────────────────────────────────────────
echo "==> Helm 레포 업데이트..."
helm repo add jetstack https://charts.jetstack.io 2>/dev/null || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update

# ── 차트별 처리 ───────────────────────────────────────────────
TARGET="${1:-all}"

if [[ "${TARGET}" == "all" || "${TARGET}" == "karpenter" ]]; then
  pull_chart \
    "karpenter" \
    "oci://public.ecr.aws/karpenter/karpenter" \
    "${KARPENTER_VERSION}" \
    "${CHARTS_DIR}/karpenter"
fi

if [[ "${TARGET}" == "all" || "${TARGET}" == "cert-manager" ]]; then
  pull_chart \
    "cert-manager" \
    "jetstack" \
    "${CERT_MANAGER_VERSION}" \
    "${CHARTS_DIR}/cert-manager"
fi

if [[ "${TARGET}" == "all" || "${TARGET}" == "monitoring" ]]; then
  pull_chart \
    "kube-prometheus-stack" \
    "prometheus-community" \
    "${KUBE_PROMETHEUS_STACK_VERSION}" \
    "${CHARTS_DIR}/monitoring/kube-prometheus-stack"
fi

echo ""
echo "==> 완료. helmfile에서 로컬 경로 참조:"
echo "    karpenter:              chart: ./karpenter/base"
echo "    cert-manager:           chart: ./cert-manager/base"
echo "    kube-prometheus-stack:  chart: ./monitoring/kube-prometheus-stack/base"
