# ARCHITECTURE — k8s-shopify-translations-pocharlies

Manifests de `shopify-translation-app`. Código en `pocharlies-org/shopify-translation-app`.

## Clientes y versiones
- Un Deployment web (puerto 3458, `skirmshop.e-dani.com/translations`, ns `skirmshop`). Tronco: `main` (Application `shopify-translations`, path `k8s`).

## Dependencias (ambos sentidos)
- Base `pocharlies/k8s-shopify-framework-pocharlies//base?ref=deploy/prod`; imagen `harbor.e-dani.com/homelab/shopify-translation-app`; `externalsecret.yaml`; Postgres compartido; Brain por URL de cluster.

## Stack
Kustomize con base remota; sin Helm.

## Componentes compartidos
Base del framework; `scripts/verify-scopes.sh` + `k8s/expected-scopes.txt`.

## Cómo se construye
`k8s/kustomization.yaml` (parches inline) y `k8s/externalsecret.yaml` (Vault → external-secrets).

## Tests y validaciones
`reusable-ci.yml`; `scripts/verify-scopes.sh` para los scopes.

## CI/CD y despliegue
`ci.yml`, `release.yml`. ArgoCD lee `main`.

## Decisiones y trampas
- El nombre del repo es plural (`translations`), el de la app y la fuente singular (`translation-app`).
