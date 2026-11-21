# Bazarr Helm Chart

Deploys [Bazarr](https://www.bazarr.media/) from LinuxServer's image, [`lscr.io/linuxserver/bazarr`](https://github.com/linuxserver/docker-bazarr), the one Bazarr's docs recommend.
Bazarr takes the series and movies from Sonarr and Radarr, finds subtitles for them, and writes each one beside its video.

The chart is opinionated: Bazarr keeps its data in Postgres rather than SQLite.
It runs one replica:

- A Deployment that stops the old pod before starting the new one, since two copies of Bazarr can't share one database.
- A volume for `/config` (`config.yaml`, logs, backups and cache) and one for `/data` (the TV and movie libraries), each an existing claim or a claim the chart creates.
- A Service on Bazarr's port, 6767, and an optional Gateway API `HTTPRoute` to it.
- A start-up, liveness and readiness probe on that port, since Bazarr has no health endpoint that works without a login.
  Start-up gets 5 minutes, since the first start creates Bazarr's schema in Postgres.

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
| `persistence.data.existingClaim` | none; the chart creates a claim |
| `persistence.data.storageClassName` | the cluster's default class |
| `persistence.data.size` | none; required unless `existingClaim` is set |
| `httpRoute.enabled` | `false` |
| `httpRoute.parentRefs` | none; required when enabled |
| `httpRoute.hostnames` | none |

### What the chart sets

Bazarr reads only its Postgres settings from the environment.
Everything else (its login, API key, the connections to Sonarr and Radarr, subtitle providers and languages) is set in the web UI and kept in its database.
Set the login on first start: Bazarr has none until one is set.

### Postgres

Bazarr needs one database, `postgres.database`, owned by the user in the Secret; Bazarr creates its tables in it.
The user and password can come from one Secret or two.
Their keys default to those of a `kubernetes.io/basic-auth` Secret, which is also how CloudNativePG names them.

`PGSSLCERT` is set to `/tmp/postgresql.crt`, as [Bazarr's wiki](https://wiki.bazarr.media/Additional-Configuration/PostgreSQL-Database/) says is needed when it doesn't run as root.

### User and group

LinuxServer's image starts as root, gives `/config` to `puid` and `pgid`, then runs Bazarr as them.
They need to be able to write to `/data` as well, since Bazarr writes subtitles there.

### Storage

`/data` holds the TV and movie libraries.
Mount them at the same paths Sonarr and Radarr see, so the paths they report need no mapping in Bazarr.

A claim the chart creates is `ReadWriteOnce`.
To share `/data` with Sonarr and Radarr, give an existing claim that all three mount.

## Requirements

- A Postgres server, with the database and user made beforehand.
- One or two Secrets holding the Postgres user and password.
- A storage class for the claims the chart creates, the cluster's default unless named.
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
    existingClaim: media
```

## Development

Pull requests run:

- `helm lint --strict`, and the rendered chart checked by kubeconform against Kubernetes 1.37.
- helm-unittest's tests in `tests/`.
- An install and upgrade with chart-testing in a kind cluster, against a throwaway Postgres from `ci/kind`.

Commits follow Conventional Commits.
Releases are versioned and tagged automatically from `main`, and published to the Helm repository on this repo's GitHub Pages.
