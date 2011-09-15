name "zabbix-cloudwatch"
description "Cloudwatch scripts"
override_attributes "zabbixaws" => {
        "account1" => {
                "name" => "myaccount",
                "key" => "mykey",
                "secret" => "mysecret"
        },
        "account2" => {
                "name" => "myaccount2",
                "key" => "mykey",
                "secret" => "mysecret"
        }
}

run_list [
        "recipe[zabbix::agent]",
        "recipe[zabbix-aws::agent-scripts]",
        "recipe[zabbix-aws::agent-autoregister"
]

