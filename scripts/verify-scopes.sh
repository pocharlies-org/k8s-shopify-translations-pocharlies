#!/usr/bin/env bash
#
# verify-scopes.sh — guards the Shopify access scopes of this app's Deployment.
#
# Why this exists:
#   The shared framework base (k8s-shopify-framework-pocharlies//base) sets
#   `SCOPES=read_products,write_products` as a DIRECT container env var. In
#   Kubernetes a direct `env` entry overrides the same key coming from
#   `envFrom` (the app Secret) — so the real scopes stored in the Secret were
#   being silently dropped. Each overlay must therefore re-assert its real
#   SCOPES in its kustomization patch. This test renders the overlay and fails
#   if the effective SCOPES on container `app` don't match the expected set,
#   catching the regression before it ships.
#
# Compares as an unordered SET (Shopify ignores scope order).
#
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
overlay="$root/k8s"
expected_file="$overlay/expected-scopes.txt"

if [ ! -f "$expected_file" ]; then
  echo "FAIL: missing $expected_file" >&2
  exit 2
fi

# Renderer: prefer standalone kustomize, fall back to `kubectl kustomize`.
if command -v kustomize >/dev/null 2>&1; then
  render() { kustomize build "$overlay"; }
elif command -v kubectl >/dev/null 2>&1; then
  render() { kubectl kustomize "$overlay"; }
else
  echo "FAIL: need either 'kustomize' or 'kubectl' on PATH" >&2
  exit 2
fi

actual="$(render | python3 -c '
import sys, yaml
vals = []
for d in yaml.safe_load_all(sys.stdin):
    if not d or d.get("kind") != "Deployment":
        continue
    for c in d["spec"]["template"]["spec"]["containers"]:
        if c.get("name") != "app":
            continue
        for e in c.get("env", []) or []:
            if e.get("name") == "SCOPES":
                vals.append(e.get("value", ""))
if len(vals) != 1:
    sys.stderr.write(f"expected exactly one SCOPES env on container app, found {len(vals)}: {vals}\n")
    sys.exit(3)
sys.stdout.write(vals[0])
')"

norm() { tr ',' '\n' <<<"$1" | sed 's/[[:space:]]//g; /^$/d' | sort | paste -sd, -; }
exp_n="$(norm "$(cat "$expected_file")")"
act_n="$(norm "$actual")"

if [ "$exp_n" != "$act_n" ]; then
  echo "FAIL: SCOPES mismatch on container 'app'"
  echo "  expected: $exp_n"
  echo "  actual:   $act_n"
  exit 1
fi

echo "OK: SCOPES = $act_n"
