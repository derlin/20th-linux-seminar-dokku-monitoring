FROM mysql:8.0.14

# fix UTF-8 accents in init scripts
ENV LANG C.UTF-8

# mandatory
ENV MYSQL_ROOT_PASSWORD root

# set credentials
ENV MYSQL_DATABASE bbdata2
ENV MYSQL_USER bbdata-admin
ENV MYSQL_PASSWORD bbdata

# set init files: create the db
COPY bbdata2-structure.sql /docker-entrypoint-initdb.d/01.sql
COPY test-data.sql /docker-entrypoint-initdb.d/02.sql