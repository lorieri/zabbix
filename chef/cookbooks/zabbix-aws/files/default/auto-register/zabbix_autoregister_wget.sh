#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#Testing argument
test -z "$1" && { echo "Usage: zabbix_register_api.sh  [mytag]"; exit 0; }

MYTAG=$1

#api url
URL='zabbix.mydomain.com.br/zabbix/api_jsonrpc.php'
USER='user'
PASSWORD='password'

#machine's amazon informations
DNS=`wget --tries=1 --timeout=15 -q -O- http://169.254.169.254/latest/meta-data/hostname`
ISID=`wget --tries=1 --timeout=15 -q -O- http://169.254.169.254/latest/meta-data/instance-id`

#testing amazon informations
test -z "$DNS" && { echo "Erro ao pegar DNS"; exit 0; }
test -z "$ISID" && { echo "Erro ao pegar Instance-id";  exit 0; }

echo "-> Authenticating..."
AUTH=`wget --tries=1 --timeout=15 -q -O- --header="Content-Type: application/json" --post-data='{"jsonrpc":"2.0","method":"user.authenticate","params":{"user":"'"$USER"'","password":"'"$PASSWORD"'"},"id": 1}' "$URL" |sed -n 's/.*"result":"\([a-f0-9]*\)".*/\1/p'`

#Testing Auth
test -z "$AUTH" && { echo "Error authenticating" ; exit 0 ; }

echo "-> Searching hostgroups..."
# From tag's group and Discovered hosts
GRPS=`wget --tries=1 --timeout=15 -q -O- --header="Content-Type: application/json" --post-data='{"jsonrpc":"2.0","method":"hostgroup.get","params":{"filter":{"name": ["'"$MYTAG"'","Discovered hosts"]}},"id": 1,"auth":"'"$AUTH"'"}' "$URL"| sed -n 's/.*"result":\[\([^]]*\)\].*/\1/p'`

#checking groups 
echo "$GRPS" |grep -o groupid|wc -l|grep -qx 2 || { echo "Error getting groups"; exit 0 ; }

echo "-> Getting LinuxBasic and Tag's template..."
TEMPLATES=`wget --tries=1 --timeout=15 -q -O- --header="Content-Type: application/json" --post-data='{"jsonrpc":"2.0","method":"template.get","params":{"filter":{"host":["Template_LinuxBasic","Template_'"$MYTAG"'"]}},"id": 1,"auth":"'"$AUTH"'"}' "$URL"| sed -n 's/.*"result":\[\([^]]*\)\].*/\1/;s/"hostid":"[^"]*",//gp'`

#checking templates
echo "$TEMPLATES" |grep -o templateid|wc -l|grep -qx 2 || { echo "Error getting templates"; exit 0 ; }

echo "-> Registering host..."

#building api's json
REGISTER=`wget --tries=1 --timeout=20 -q -O- --header="Content-Type: application/json" $URL --post-data='{
  "jsonrpc":"2.0",
  "method" : "host.create",
  "params":{
      "host":"'"$ISID"'",
      "ip":"0.0.0.0",
      "useip": 0,
      "dns":"'"$DNS"'",
      "port":10050,
      "groups":[
          '"$GRPS"'
      ],  
      "templates":[
          '"$TEMPLATES"'
      ]
  },      
  "auth":"'"$AUTH"'",
  "id":1
}
'`

echo $REGISTER
echo "$REGISTER"|grep -q '"hostids":\["[0-9]*"\]' || { echo "Error registering $DNS !!!!"; exit 0 ; }
echo "-> $DNS registered !!"
