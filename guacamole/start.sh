docker compose up -d mysql

watch -n2 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

MYSQL_ROOT_PASSWORD=$(grep ^MYSQL_ROOT_PASSWORD .env | cut -d= -f2)

docker run --rm guacamole/guacamole:1.5.5 \
  /bin/sh -lc '/opt/guacamole/bin/initdb.sh --mysql' \
| docker exec -i guacamole-mysql-1 \
  sh -lc "mysql -uroot -p\"$MYSQL_ROOT_PASSWORD\" guacamole_db"

docker compose up -d guacd guacamole


