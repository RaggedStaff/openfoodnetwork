#!/bin/bash

# This script archives and then deletes all Orders over 6 years old. It then removes Customer accounts, older than 1 year, without any Orders assocaited.

# This script should be called automatically on the first of the month.

# function to execute a SELECT query (everything after FROM supplied as $2) & backup the results to a (gzipped) file.

backup_qry () {}
  cd "$CURRENT_PATH"
  mkdir -p "db/$1-backup"
  echo "Backing up $1 data"
  psql -eh "$DB_HOST" -U "$DB_USER" -d "$DB" -c "SELECT * FROM $2" \o |gzip "db/$1-backup/$1.$date.sql.gz"
  echo "$1 Data saved to file: db/$1-backup/orders.$date.sql.gz"
}


# function to execute a DELETE query (everything after FROM supplied as $2).

delete_qry () {}
  cd "$CURRENT_PATH"
  mkdir -p "db/$1-backup"
  echo "Deleting $1 data"
  psql -eh "$DB_HOST" -U "$DB_USER" -d "$DB" -c "DELETE FROM $2"
  echo "$1 Data deleted"
}



set -e
source "`dirname $0`/includes.sh"

echo "Checking environment variables"
require_env_vars CURRENT_PATH SERVICE DB_HOST DB_USER DB

echo "setting date variable"
printf -v date '%(%Y-%m-%d)T\n' -1
echo "Date set to: $date "

printf -v archive_date '%(%F)T\n' $(( $(date +%s) - 189345600 ))
echo "Archive date set to: $archive_date"

echo "setting query variables"
orders_qry=" spree_orders WHERE completed_at<now() - INTERVAL '6 years"
customers_qry=" customers WHERE id IN (SELECT id FROM customers as a  \n
      join (select customer_id, max(completed_at) as last_order from spree_orders   group by customer_id) as b \n
      on a.id=b.customer_id where last_order< now() - INTERVAL '6 years') \n
      AND create_date < now() - INTERVAl '1 year'"


backup_qry "orders" "$orders_qry"

delete_qry "orders" "$orders_qry"

backup_qry "customers" "$customers_qry"

delete_qry "customers" "$customers_qry"
