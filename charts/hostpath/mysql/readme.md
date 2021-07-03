# MySQL Hostpath

## How to Override

Change `MY_KEY`, `MY_VALUE`, & `FOLDER`

```
mysql-hostpath:
  deployment:
    affinity:
      nodeSelectors:
      - key: MY_KEY
        value: MY_VALUE
    database: '{{ .Release.Name }}-db'
    hostPath:
      mountPath: /k8s/FOLDER/{{ .Release.Name }}/db
      name: mysql-data
```
