#!/bin/bash
VERSION="0.4"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

#============================================================
#= snapshot.sh v0.2 created by mrgr                         =
#= Please consider voting for delegate mrgr                 =
#============================================================
#============================================================
#= snapshot.sh v0.3 created by Mx                           =
#= Please consider voting for delegate Mx                   =
#============================================================
#============================================================
#= snapshot.sh v0.4 created by bfx                          =
#= Please consider voting for delegate bfx                  =
#============================================================
echo " "

if [ ! -f ../shift-lisk/app.js ]; then
  echo "Error: No shift installation detected. Exiting."
  exit 1
fi

if [ "\$USER" == "root" ]; then
  echo "Error: SHIFT should not be run be as root. Exiting."
  exit 1
fi

SHIFT_CONFIG=~/shift-lisk/config.json
DB_NAME="$(grep "database" $SHIFT_CONFIG | cut -f 4 -d '"')"
DB_USER="$(grep "user" $SHIFT_CONFIG | cut -f 4 -d '"')"
DB_PASS="$(grep "password" $SHIFT_CONFIG | cut -f 4 -d '"' | head -1)"
SNAPSHOT_COUNTER=snapshot/counter.json
if [ ! -f "snapshot/counter.json" ]; then
  mkdir -p snapshot
  sudo chmod a+x shift-snapshot.sh
  echo "0" > $SNAPSHOT_COUNTER
  sudo chown postgres:${USER:=$(/usr/bin/id -run)} snapshot
  sudo chmod -R 777 snapshot
fi
SNAPSHOT_DIRECTORY=snapshot/


NOW=$(date +"%d-%m-%Y - %T")
################################################################################

create_snapshot() {
  export PGPASSWORD=$DB_PASS
  echo " + Stopping shift-lisk"
  echo "--------------------------------------------------"
  echo "..."
  pm2 stop app
  ~/shift-lisk/shift_manager.bash stop

  echo " + Creating snapshot"
  echo "--------------------------------------------------"
  echo "..."
  pg_dump $DB_NAME | gzip > $SNAPSHOT_DIRECTORY'blockchain.db.gz'
  blockHeight=`psql -d $DB_NAME -U $DB_USER -h localhost -p 5432 -t -c "select height from blocks order by height desc limit 1;"`
  dbSize=`psql -d $DB_NAME -U $DB_USER -h localhost -p 5432 -t -c "select pg_size_pretty(pg_database_size('$DB_NAME'));"`

  echo "$NOW -- OK snapshot created successfully at block$blockHeight ($dbSize)."
  echo "--------------------------------------------------"
  echo "..."
  echo " + Restarting shift-lisk"
  echo "..."
  pm2 start app
  ~/shift-lisk/shift_manager.bash start

  echo " + Moving snapshot to ~/shift-lisk"
  echo "--------------------------------------------------"
  echo "..."
  mv snapshot/blockchain.db.gz ~/shift-lisk/blockchain.db.gz
}

restore_snapshot(){
  echo " + Restoring snapshot"
  echo "--------------------------------------------------"
  SNAPSHOT_FILE=`ls -t ~/shift-lisk/blockchain.db.gz | head  -1`
  if [ -z "$SNAPSHOT_FILE" ]; then
    echo "****** No snapshot to restore, please consider create it first"
    echo " "
    exit 1
  fi
  echo "Snapshot to restore = $SNAPSHOT_FILE"

#snapshot restoring..
  ~/shift-lisk/shift_manager.bash rebuild

  if [ $? != 0 ]; then
    echo "X Failed to restore."
    exit 1
  else
    echo "OK - snapshot restored successfully."
  fi

}

################################################################################

case $1 in
"create")
  create_snapshot
  ;;
"restore")
  restore_snapshot
  ;;
"hello")
  echo "Hello Shift - $NOW"
  ;;
"help")
  echo "Available commands are: "
  echo "  create   - Create new snapshot"
  echo "  restore  - Restore the last snapshot available in folder snapshot/"
  ;;
*)
  echo "Error: Unrecognized command."
  echo ""
  echo "Available commands are: create, restore, help"
  echo "Try: bash shift-snapshot.sh help"
  ;;
esac
