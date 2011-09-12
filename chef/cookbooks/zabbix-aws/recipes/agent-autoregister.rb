#### PLEASE INCLUDE THIS RECIPE AT THE END OF YOUR GROUP RECIPE

node[:tags].each do |p|
        if p =~ /^zabbix/
                if p !~ /REGISTERED$/

                        z = p.split("-")[1]

                        Chef::Log.info("Trying to register in the Zabbix using the Template and Group: #{z}")


			cookbook_file "/root/zabbix_autoregister.sh" do
				source "auto-register/zabbix_autoregister_api.sh"
				owner "root"
				group "root"
				mode "0700"
				notifies :restart, resources(:service => "zabbix-agent" ), :delayed
			end

			execute "sh /root/zabbix_autoregister.sh #{z}" do
				user "root"
				notifies :restart, resources(:service => "zabbix-agent" ), :delayed
			end

			Chef::Log.info("Chaging Tag #{p} to #{p}-REGISTERED")
			untag("#{p}")
			tag("#{p}-REGISTERED")

                else
                        Chef::Log.info("Tag marked as registered: #{p}")
                end
        end
end

