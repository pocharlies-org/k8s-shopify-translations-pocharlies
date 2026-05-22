# k8s-shopify-translations-pocharlies

GitOps runtime for the Skirmshop translations Shopify app.

Status on 2026-05-22:

- Docker legacy runtime on `sauvage`: `translations-app` on port `3458`.
- Kubernetes image: `harbor.e-dani.com/homelab/shopify-translation-app:20260522-659327b`.
- Primary database: `translations` in `databases/postgres-shared`.
- Synapse read database: `synapse` in `databases/postgres-shared`.
- RabbitMQ target: `shared-rabbitmq.databases.svc.cluster.local` vhost `/synapse`.
- Temporary cutover bridge: `hostPort: 3458` on Sauvage, so the existing
  NGINX `/translations/` proxy to `127.0.0.1:3458` can be served by k8s after
  the Docker container is stopped.

Cutover rule: do not stop the Docker legacy container until `/translations` has
been routed to this Deployment and manual translation triggers have been smoke
tested against the Synapse queue path.
