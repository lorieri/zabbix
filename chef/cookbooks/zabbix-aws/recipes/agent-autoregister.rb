#### PLEASE INCLUDE THIS RECIPE AT THE END OF YOUR GROUP RECIPE

if not expected_tag
	expected_tag="REGISTERED"
end

node[:tags].each do |p|
        if p =~ /^zabbix/
                if p !~ /#{expected_tag}$/

                        z = p.split("-")[1]

                        Chef::Log.info("Trying to register in the Zabbix using the Template and Group: #{z}")


			template "/root/zabbix_autoregister.sh" do
				source "auto-register/zabbix_autoregister_wget.sh.erb"
                                #use the one below if you have curl available and not wget
				#source "auto-register/zabbix_autoregister_curl.sh"
				owner "root"
				group "root"
				mode "0700"
				notifies :restart, resources(:service => "zabbix-agent" ), :delayed
			end

			execute "sh /root/zabbix_autoregister.sh #{z}" do
				user "root"
				notifies :restart, resources(:service => "zabbix-agent" ), :delayed
			end

			newtag = "zabbix-#{z}-#{expected_tag}"
			Chef::Log.info("Chaging Tag #{p} to #{newtag}")
			untag(p)
			tag(newtag)

                else
                        Chef::Log.info("Tag marked as registered: #{p}")
                end
        end
end

