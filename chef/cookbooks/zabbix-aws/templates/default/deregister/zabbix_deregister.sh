#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#Testing argument
test -z "$1" -o -z "$2" && { echo "Usage: zabbix_deregister.sh [mygroup] [myaccount]"; exit 1; }

URL='zabbix.mydomain.com.br/zabbix/api_jsonrpc.php'
USER=admin
PASSWORD=zabbix

GROUP="$1"
ACCOUNT="$2"

LISTAAMAZON=`mktemp`
LISTAZABBIX=`mktemp`
LISTAZABBIXNAME=`mktemp`
LISTAIDS=`mktemp`
LISTATMP=`mktemp`

#exit funcion
atexit() {
        rm -f $LISTAAMAZON
        rm -f $LISTAZABBIX
        rm -f $LISTAZABBIXNAME
        rm -f $LISTAIDS
	rm -f $LISTATMP
}
trap atexit 0

#getting amazon instance lists
/usr/local/bin/zabbix_get_instances.py "$ACCOUNT"  > $LISTATMP || exit 1

sort $LISTATMP > $LISTAAMAZON

#testing list
test "$(cat $LISTAAMAZON |wc -l)" -gt 0 || exit 0

echo "-> Authenticating..."
AUTH=`wget --timeout=15 -q -O- --header="Content-Type: application/json" --post-data='{"jsonrpc":"2.0","method":"user.authenticate","params":{"user":"'"$USER"'","password":"'"$PASSWORD"'"},"id": 1}' "$URL" |sed -n 's/.*"result":"\([a-f0-9]*\)".*/\1/p'`

#Testing Auth
test -z "$AUTH" && { echo "Error authenticating" ; exit 1 ; }

echo "-> Searching hostgroup..."
#GROUPS is a reserved name for bash
GRPS=`wget --timeout=15 -q -O- --header="Content-Type: application/json" --post-data='{"jsonrpc":"2.0","method":"hostgroup.get","params":{"filter":{"name": ["'"$GROUP"'"]}},"id": 1,"auth":"'"$AUTH"'"}' "$URL" | sed -n 's/.*\[{"groupid":"\([0-9]*\)"}\].*/\1/p'`

#checking groups 
echo "$GRPS" |grep -o "^[0-9][0-9]*$" |wc -l|grep -qx 1 || { echo "Error getting groups"; exit 1 ; }


echo "-> Searching hosts..."
wget --timeout=15 -q -O- --header="Content-Type: application/json" --post-data='{"jsonrpc":"2.0","method":"host.get","params":{"output":"extend","groupids":["'"$GRPS"'"],"filter":{"status":[0]}},"id": 1,"auth":"'"$AUTH"'"}' "$URL" | grep -o '"hostid":"[0-9]*"\|"host":"[^"]*"' | tr ' ' '\n' > $LISTAZABBIX

echo "-> Searching for non-matched hosts"
sed -n 's/"host":"\([^"]*\)"/\1/p' $LISTAZABBIX | sort > $LISTAZABBIXNAME
HOST=`grep -xv -f $LISTAAMAZON $LISTAZABBIXNAME `

#building deleting list
test -z "$HOST" && { echo "Nothing to do"; exit 0; }

for d in $HOST
do
	HOSTID=`grep '"host":"'"$d"'"' -B1 $LISTAZABBIX |head -1`
	DEL=$DEL'{'"$HOSTID"'}'

	ID=`echo "$HOSTID" | grep -o "[0-9]*"`

	RESULT=`wget --timeout=15 -q -O- --header="Content-Type: application/json" --post-data='{"jsonrpc":"2.0","method":"host.update","params":{"hostid": "'"$ID"'","status": 1},"auth":"'"$AUTH"'","id":1}' "$URL"`
	echo $RESULT |
		  grep -q result && echo "Hosts $d disabled" ||  
		  { echo "Error disabling hosts: $RESULT"; exit 1; }


done

DEL=`echo $DEL |sed "s/}{/},{/g"`

###### IF YOU WANT TO DELETE THE MACHINE, USE THE LINE BELOW
#RESULT=`wget --timeout=15 -q -O- --header="Content-Type: application/json" --post-data='{"jsonrpc":"2.0","method":"host.delete","params":['"$DEL"'],"id": 1,"auth":"'"$AUTH"'"}' "$URL"`

#echo $RESULT |
#  grep -q result && echo "Hosts removed" ||  
#  { echo "Error removing hosts: $RESULT"; exit 1; }
