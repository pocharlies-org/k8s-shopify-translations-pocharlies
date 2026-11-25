# ARCHITECTURE — k8s-shopify-translations-pocharlies

Manifests de `shopify-translation-app`. Código en `pocharlies-org/shopify-translation-app`.

## Clientes y versiones
- Un Deployment web (puerto 3458, `skirmshop.e-dani.com/translations`, ns `skirmshop`). Tronco: `main` (Application `shopify-translations`, path `k8s`).

## Dependencias (ambos sentidos)
- Base `pocharlies/k8s-shopify-framework-pocharlies//base?ref=deploy/prod`; imagen `harbor.e-dani.com/homelab/shopify-translation-app`; `externalsecret.yaml`; Postgres compartido; LiteLLM (`litellm.e-dani.com`). El Brain se retiró en SC-5827: el Deployment ya no lleva `BRAIN_URL`, `BRAIN_API_KEY` ni `TRANSLATION_BACKEND`.

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
- `k8s-stage/` es el stage (Application `shopify-translations-stage`, ns `skirmshop`): la misma
  imagen sobre la tienda de prueba `sii-test-sc1800.myshopify.com`, con su Secret
  (`skirmshop-translations-stage`) y su BD (`translations_stage`). La app es de un solo
  comerciante, así que el stage es otra instalación de la app, no la misma con otra tienda.

## Decisiones y trampas
- El nombre del repo es plural (`translations`), el de la app y la fuente singular (`translation-app`).
