name "zabbix-scripts"
description "Cloudwatch, deregistration and  aggregation scripts"
override_attributes "zabbixaws" => {
        "account1" => {
                "name" => "EasyName1",
                "key" => "mykey",
                "secret" => "mysecret"
        },
        "account2" => {
                "name" => "EasyName2",
                "key" => "mykey",
                "secret" => "mysecret"
        },
        "auto" => {
                "user" => "admin",
                "password" => "zabbix",
                "jsonurl" => "zabbix.mydomain.com.br/zabbix/api_jsonrpc.php"
        }
}

run_list [
        "recipe[zabbix::agent]",
        "recipe[zabbix-aws::agent-cloudwatch]",
        "recipe[zabbix-aws::agent-deregister]"
]

