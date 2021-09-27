# Postgres Hostpath

## How to Override

### Simple
```
postgres:
  deployment:
    db:
      auth: password
      name: NAME_GOES_HERE
    hostPath:
      mountPath: /eons/local/{{ .Release.Namespace }}/{{ .Release.Name }}/pg-data
      name: pg-data
  secrets:
    DB_PASSWORD: PASSWORD_GOES_HERE
    DB_USER: USER_GOES_HERE
```

### Complex
```
postgres:
  deployment:
    resources:
      requests:
        cpu: 500m
        memory: 1000Mi
      limits:
        cpu: 4000m
        memory: 4000Mi
    image: postgres:12.4-alpine
    priorityClass: prod-low
    db:
      auth: password
      name: NAME_GOES_HERE
    hostPath:
      mountPath: /eons/local/{{ .Release.Namespace }}/{{ .Release.Name }}/db
      name: db
  secrets:
    DB_PASSWORD: PASSWORD_GOES_HERE
    DB_USER: USER_GOES_HERE
```
