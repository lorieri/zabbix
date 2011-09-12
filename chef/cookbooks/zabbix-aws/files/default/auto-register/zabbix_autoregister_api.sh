#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#Testing argument
test -z "$1" && { echo "Usage: zabbix_register_api.sh  [mytag]"; exit 1; }

MYTAG=$1

#api url
URL='zabbix.mydomain.com.br/zabbix/api_jsonrpc.php'
USER='user'
PASSWORD='password'

#machine's amazon informations
DNS=`wget -q -O- http://169.254.169.254/latest/meta-data/hostname`
ISID=`wget -q -O- http://169.254.169.254/latest/meta-data/instance-id`

#testing amazon informations
test -z "$DNS" && { echo "Erro ao pegar DNS"; exit 1; }
test -z "$ISID" && { echo "Erro ao pegar Instance-id";  exit 1; }


echo "-> Authenticating..."
AUTH=`curl -s -X POST -H "Content-Type: application/json" $URL -d '{"jsonrpc":"2.0","method":"user.login","params":{"user":"'"$USER"'","password":"'"$PASSWORD"'"},"id": 1}'|sed -n 's/.*"result":"\([a-f0-9]*\)".*/\1/p'`

#Testing Auth
test -z "$AUTH" && { echo "Error authenticating" ; exit 1 ; }

echo "-> Searching hostgroups..."
# From tag's group and Discovered hosts
GROUPS=`curl -s -X POST -H "Content-Type: application/json" $URL -d '{"jsonrpc":"2.0","method":"hostgroup.get","params":{"filter":{"name": ["'"$MYTAG"'","Discovered hosts"]}},"id": 1,"auth":"'"$AUTH"'"}' | sed -n 's/.*"result":\[\([^]]*\)\].*/\1/p'`

#checking groups 
echo "$GROUPS" |grep -o groupid|wc -l|grep -qx 2 || { echo "Error getting groups"; exit 1 ; }

echo "-> Getting LinuxBasic and Tag's template..."
TEMPLATES=`curl -s -X POST -H "Content-Type: application/json" $URL -d '{"jsonrpc":"2.0","method":"template.get","params":{"filter":{"host":["Template_LinuxBasic","Template_'"$MYTAG"'"]}},"id": 1,"auth":"'"$AUTH"'"}'| sed -n 's/.*"result":\[\([^]]*\)\].*/\1/;s/"hostid":"[^"]*",//gp'`

#checking templates
echo "$TEMPLATES" |grep -o templateid|wc -l|grep -qx 2 || { echo "Error getting templates"; exit 1 ; }

echo "-> Registering host..."

test -z "$DNS" && { echo "Error getting DNS"; exit 1; }
test -z "$ISID" && { echo "Erro getting Instance-id";  exit 1; }

#building api's json
REGISTER=`curl -s -X POST -H "Content-Type: application/json" $URL  -d '{
  "jsonrpc":"2.0",
  "method" : "host.create",
  "params":{
      "host":"'"$ISID"'",
      "ip":"0.0.0.0",
      "useip": 0,
      "dns":"'"$DNS"'",
      "port":10050,
      "groups":[
          '"$GROUPS"'
      ],  
      "templates":[
          '"$TEMPLATES"'
      ]
  },      
  "auth":"'"$AUTH"'",
  "id":1
}
'`
echo "$REGISTER"|grep -q '"hostids":\["[0-9]*"\]' || { echo "Error registering $DNS !!!!"; exit 1 ; }
echo "-> $DNS registered !!"
