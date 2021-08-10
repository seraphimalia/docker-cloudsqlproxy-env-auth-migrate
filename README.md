# Flyway Action via CloudSQL Proxy

I struggled so much to get CloudSQL Proxy to run as a container service that I ended up writing this action which uses will start up a cloudsqlproxy instance and execute the Flyway migrate command. It also runs the repair command if migrate fails.

## Usage

```yaml
name: Main
on:
  - push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Migrate Database
        uses: seraphimalia/docker-cloudsqlproxy-env-auth-migrate:master
        with:
          serviceAccountCreds: ${{ secrets.GOOGLE_CLOUDSQL_SERVICE_ACCOUNT }}
          cloudSqlInstance: ${{ env.CLOUDSQL_INSTANCE }}
          databaseName: ${{ env.DATABASE_NAME }}
          databaseUser: ${{ secrets.DATABASE_USER }}
          databasePassword: ${{ secrets.DATABASE_PASSWORD }}
          migrationScriptsLocation: migration/sql
```
