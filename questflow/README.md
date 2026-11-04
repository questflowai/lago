# Questflow Lago fork

The upstream Lago repository pins `api` and `front` as Git submodules. The
Questflow modifications are maintained as reviewable patches in this repository
so the pinned upstream source and local changes can be rebuilt together without
publishing commits to upstream submodule repositories.

Starting from a clean checkout, apply both patches with:

```sh
./questflow/apply-fork.sh
```

Then build the patched source for the target platform. For GKE on x86 nodes,
the images must include `linux/amd64`. Use immutable tags and image digests for
releases; never include environment files or runtime secrets in build contexts.

```sh
docker buildx build --platform linux/amd64 --tag "$API_IMAGE" --push ./api
docker buildx build --platform linux/amd64 --tag "$FRONT_IMAGE" --push ./front
```

`cloudbuild.yaml` provides a source-free Cloud Build option: it clones a
reviewed commit, applies the pinned patches, builds `linux/amd64` images and
publishes them to the supplied Artifact Registry image references. Override
`_REVISION`, `_API_IMAGE`, and `_FRONT_IMAGE` with release-specific values.
Ensure the Cloud Build service account has the required registry permissions.
The build is not a production deployment and must be validated before use.

The patches preserve the upstream submodule revisions in the enclosing commit.
After an upstream update, review and rebase the patches before building. Keep
the upstream licenses and notices and retain the corresponding patched source
for each release.

## Current fork behavior

- `QUESTFLOW_LAGO_FORK_ENABLED=true` enables the fork's premium feature check
  without calling Lago's license service. Organization-level integration and
  feature flags remain separate. This does not imply every function is tested.
- Segment and Sentry initialization, frontend session replay, and the OTEL
  exporter are disabled. Stripe SDK telemetry is disabled; Stripe payment
  requests and configured webhooks remain separate business communications.
- Cross-organization administrators must be authenticated, have `cs_admin`,
  and match `QUESTFLOW_ADMIN_EMAIL_DOMAIN`. The upstream SSO restriction still
  applies. Admin grant and revocation require a controlled operational process.
- Redis TLS verifies the server certificate. Configured Redis endpoints must
  have a verifiable certificate chain and matching hostname.
- Email templates do not load the upstream hosted logo by default; a controlled
  URL can be supplied through `QUESTFLOW_EMAIL_LOGO_URL`.

The test-only Stripe proxy is enabled only if both `QUESTFLOW_LAGO_POC=true` and
`QUESTFLOW_STRIPE_PROXY` are set. Do not use that proxy or test credentials in
production. The GKE deployment, Cloud SQL, Redis TLS, GCS, administrative
bootstrap, network access policy and live payment integration have not yet
been verified by this repository. Billing behavior and upstream dependencies
must be validated before production traffic is enabled.
