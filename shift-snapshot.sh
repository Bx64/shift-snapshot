#!/bin/bash
VERSION="0.5"

# CONFIG
SHIFT_DIRECTORY=~/shift-m

# EXPORT
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

#============================================================
#= snapshot.sh v0.2 created by mrgr                         =
#= Please consider voting for delegate mrgr                 =
#============================================================

#============================================================
#= snapshot.sh v0.5 created by Mx                           =
#= Please consider voting for delegate 'mx'                 =
#============================================================

echo " "

if [ ! -f ${SHIFT_DIRECTORY}/app.js ]; then
  echo -e "Error: No shift-lisk installation detected in the directory ${SHIFT_DIRECTORY} \nPlease, change config: nano shift-snapshot.sh \nor install: https://github.com/ShiftNrg/shift-lisk"
  exit 1
fi

if [ "\$USER" == "root" ]; then
  echo "Error: shift-lisk should not be run be as root. Exiting."
  exit 1
fi

SHIFT_CONFIG=${SHIFT_DIRECTORY}/config.json
DB_NAME="$(grep "database" $SHIFT_CONFIG | cut -f 4 -d '"')"
DB_USER="$(grep "user" $SHIFT_CONFIG | cut -f 4 -d '"')"
DB_PASS="$(grep "password" $SHIFT_CONFIG | cut -f 4 -d '"' | head -1)"
SNAPSHOT_COUNTER=snapshot/counter.json
SNAPSHOT_LOG=snapshot/snapshot.log
if [ ! -f "snapshot/counter.json" ]; then
  mkdir -p snapshot
  sudo chmod +x shift-snapshot.sh
  echo "0" > $SNAPSHOT_COUNTER
  sudo chown postgres:${USER:=$(/usr/bin/id -run)} snapshot
  sudo chmod -R 777 snapshot
fi
SNAPSHOT_DIRECTORY=snapshot/


NOW=$(date +"%d-%m-%Y - %T")
################################################################################

ctrlc_count=0

redTextOpen="\e[31m"
greenTextOpen="\e[1;32m"
boldTextOpen="\e[1m"
highlitedTextOpen="\e[44m"
colorTextClose="\e[0m"

create_snapshot() {
  export PGPASSWORD=$DB_PASS
  echo -e " ${boldTextOpen}+ Creating snapshot${colorTextClose}"
  echo "--------------------------------------------------"
  echo "..."
  sudo su postgres -c "pg_dump -Ft $DB_NAME > $SNAPSHOT_DIRECTORY'shift_db$NOW.snapshot.tar'"
  blockHeight=`psql -d $DB_NAME -U $DB_USER -h localhost -p 5432 -t -c "select height from blocks order by height desc limit 1;"`
  dbSize=`psql -d $DB_NAME -U $DB_USER -h localhost -p 5432 -t -c "select pg_size_pretty(pg_database_size('$DB_NAME'));"`

  if [ $? != 0 ]; then
    echo -e "${redTextOpen}X Failed to create snapshot.${colorTextClose}" | tee -a $SNAPSHOT_LOG
    exit 1
  else
    echo -e "$NOW -- ${greenTextOpen}OK snapshot created successfully${colorTextClose} at block$blockHeight ($dbSize)." | tee -a $SNAPSHOT_LOG
  fi

}

restore_snapshot(){
  echo -e " ${boldTextOpen}+ Restoring snapshot${colorTextClose}"
  echo "--------------------------------------------------"
  SNAPSHOT_FILE=`ls -t snapshot/shift_db* | head  -1`
  if [ -z "$SNAPSHOT_FILE" ]; then
    echo -e "${redTextOpen}!No snapshot to restore, please consider create it first${colorTextClose}"
    echo " "
    exit 1
  fi
  echo -e "Snapshot to restore = $SNAPSHOT_FILE"

  read -p "$(echo -e ${highlitedTextOpen}"shift-lisk node will be stopped, are you ready (y/n)?"${colorTextClose})" -r

  if [[ ! $REPLY =~ ^[Yyнд]$ ]]
  then
     echo -e "${redTextOpen}!Please stop app.js first. Then execute restore again${colorTextClose}"
     echo " "
     exit 1
  fi

bash ${SHIFT_DIRECTORY}/shift_manager.bash stop

echo -e "\n${boldTextOpen}Snapshot restoring started${colorTextClose} \nPlease keep calm and don't push the button :)"

# snapshot restoring
  export PGPASSWORD=$DB_PASS
  pg_restore -d $DB_NAME "$SNAPSHOT_FILE" -U $DB_USER -h localhost -c -n public

  if [ $? != 0 ]; then
    echo -e "${redTextOpen}X Failed to restore.${colorTextClose}"
    exit 1
  else
    echo -e "${greenTextOpen}OK snapshot restored successfully.${colorTextClose}"
  fi

bash ${SHIFT_DIRECTORY}/shift_manager.bash start

}

show_log(){
  echo " + Snapshot Log"
  echo "--------------------------------------------------"
  cat snapshot/snapshot.log
  echo "--------------------------------------------------END"
}

################################################################################

case $1 in
"create")
  create_snapshot
  ;;
"create_archive")
  create_snapshot_archive
  ;;
"restore")
  restore_snapshot
  ;;
"verify")
  echo "Hello my friend - $NOW"
  ;;
"create_verified")
  echo "Hello my friend - $NOW"
  ;;
"log")
  show_log
  ;;
"hello")
  echo "Hello my friend - $NOW"
  ;;
"test")
  start_test
  ;;
"help")
  echo "Available commands are: "
  echo "  create   - Create new snapshot"
  echo "  restore  - Restore the last snapshot available in folder snapshot/"
  echo "  log      - Display log"
  ;;
*)
  echo "Error: Unrecognized command."
  echo ""
  echo "Available commands are: create, restore, log, help"
  echo "Try: bash shift-snapshot.sh help"
  ;;
esac
