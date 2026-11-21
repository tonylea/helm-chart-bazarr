# Bazarr Helm Chart

Deploys [Bazarr](https://www.bazarr.media/) from LinuxServer's image, [`lscr.io/linuxserver/bazarr`](https://github.com/linuxserver/docker-bazarr), the one Bazarr's docs recommend.

The chart is opinionated: Bazarr keeps its data in Postgres rather than SQLite.
It runs one replica, and stops the old pod before starting the new one, since two copies of Bazarr can't share a database.

## Values

| Value | Default |
| --- | --- |
| `image.tag` | the chart's `appVersion` |
| `puid` | `1000` |
| `pgid` | `1000` |
| `timezone` | `UTC` |
| `postgres.host` | none; required |
| `postgres.port` | `5432` |
| `postgres.database` | `bazarr` |
| `postgres.username.secretKeyRef.name` | none; required |
| `postgres.username.secretKeyRef.key` | `username` |
| `postgres.password.secretKeyRef.name` | none; required |
| `postgres.password.secretKeyRef.key` | `password` |
| `resources` | none |
| `persistence.config.existingClaim` | none; the chart creates a claim |
| `persistence.config.storageClassName` | the cluster's default class |
| `persistence.config.size` | `1Gi` |
| `persistence.data` | none; at least one mount required |
| `persistence.data[].name` | required; mounted at `/data/<name>` |
| `persistence.data[].existingClaim` | none; the chart creates a claim |
| `persistence.data[].storageClassName` | the cluster's default class |
| `persistence.data[].size` | none; required unless `existingClaim` is set |
| `httpRoute.enabled` | `false` |
| `httpRoute.parentRefs` | none; required when enabled |
| `httpRoute.hostnames` | none |

## Fixed settings

The chart sets these as environment variables:

- Postgres on, with the connection from `postgres`.
- `PGSSLCERT` as `/tmp/postgresql.crt`, which [Bazarr's wiki](https://wiki.bazarr.media/Additional-Configuration/PostgreSQL-Database/) says is needed when Bazarr doesn't run as root.

## Requirements

- A Postgres server, with the database and the user that owns it made beforehand.
- One or two Secrets holding the Postgres user and password.
- A storage class for the claims the chart creates, the cluster's default unless named.
  A claim the chart creates is `ReadWriteOnce`, so sharing a data mount with Sonarr and Radarr needs an existing claim.
  Bazarr's own documentation is in [its wiki](https://wiki.bazarr.media/).
- The Gateway API's `HTTPRoute` CRD, when `httpRoute.enabled` is set.

## Usage

```sh
helm repo add bazarr https://tonylea.github.io/helm-chart-bazarr
helm install bazarr bazarr/bazarr --values my-values.yaml
```

```yaml
timezone: Europe/London
postgres:
  host: bazarr-postgres-rw
  username:
    secretKeyRef:
      name: bazarr-postgres-app
  password:
    secretKeyRef:
      name: bazarr-postgres-app
persistence:
  data:
    - name: tv
      existingClaim: tv
    - name: movies
      existingClaim: movies
```

## Development

Pull requests run:

- `helm lint --strict`, and the rendered chart checked by kubeconform against Kubernetes 1.37.
- helm-unittest's tests in `tests/`.
- An install and upgrade with chart-testing in a kind cluster, against a throwaway Postgres from `ci/kind`.

Commits follow Conventional Commits.
Releases are versioned and tagged automatically from `main`, and published to the Helm repository on this repo's GitHub Pages.
