### Restore DB
```
docker exec -t prd-dsmr-reader-db dropdb dsmrreader -U <db username>
docker exec -t prd-dsmr-reader-db createdb -O dsmrreader dsmrreader -U <db username>
gunzip <db name>.sql
cat <db name>.sql | docker exec -i prd-dsmr-reader-db psql -U <db username>
```
