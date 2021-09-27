# Django Helm Chart

## Example Config

```yaml
deployment:
  image: CHANGEME
  hostAliases:
  - hostname: api.example.com
    ip: 10.1.2.3
  priorityClass: dev-low
  secrets:
    secret_key: CHANGEME

domain: CHANGEME

secrets:
  letsencrypt:
    issuer: letsencrypt

postgres:
  deployment:
    priorityClass: dev-low
    affinity:
      nodeSelectors:
      - key: serve
        value: dev
  secrets:
    DB_USER: CHANGEME
    DB_PASSWORD: CHANGEME
```