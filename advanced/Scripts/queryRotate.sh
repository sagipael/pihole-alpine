#!/bin/bash
## script to delete all lines except last X lines
## the delete job will apply in steps

DBFILE=/etc/pihole/pihole-FTL.db

DELETE_FLAG=0
MAX_LINES="$1"
STEP="$2"

[[ -z $STEP ]] && STEP=1000
[[ $STEP -gt $MAX_LINES ]] && STEP=$MAX_LINES

if [[ ! "$MAX_LINES" =~ ^[0-9]+$  ]] ; then
	echo "not valid number of lines"
	exit
fi

if [[ ! "$STEP" =~ ^[0-9]+$  || $STEP -ge 10000  ]] ; then
	echo "step value should be between 1-10000"
	exit
fi


SIZE_BEFORE=$(ls -lh $DBFILE | awk '{print $5}')

# enable changes log
sqlite3 "${DBFILE}" ".changes on"

deleted=$STEP
deleted_total=0

query_count="SELECT count (id) FROM queries"
count=$(sqlite3 "${DBFILE}" "$query_count")
	
while [[ $count -gt $MAX_LINES   && $deleted -ge $STEP ]] ; do
	DELETE_FLAG=1
	query="DELETE FROM queries WHERE id in (SELECT id FROM queries WHER order by timestamp desc LIMIT $STEP) ; SELECT changes() FROM queries LIMIT 1"
	deleted=$(sqlite3 "${DBFILE}" "$query")
	let deleted_total=$deleted_total+$deleted

	query_count="SELECT count (id) FROM queries"
	count=$(sqlite3 "${DBFILE}" "$query_count")
done

echo 
if [[ "$DELETE_FLAG" == "1" ]] ; then
	echo "#######################"
	echo "shrinking DB file size.."
	sqlite3 "${DBFILE}" "vacuum"
	echo "#######################"
fi

SIZE_AFTER=$(ls -lh $DBFILE | awk '{print $5}')
query="select datetime(timestamp, 'unixepoch', 'localtime') FROM queries order by timestamp limit 1"
last_record="$(sqlite3 "${DBFILE}" "$query")"

echo  "All lines except last $MAX_LINES"

echo "Lines deleted		$deleted_total"
echo "Current lines count	$count"
echo "Last record in DB	$last_record"
echo "DB Size Before		$SIZE_BEFORE"
echo "DB Size After		$SIZE_AFTER"
echo
echo "End"


exit
