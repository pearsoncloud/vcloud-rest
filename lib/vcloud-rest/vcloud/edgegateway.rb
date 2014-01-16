module VCloudClient
  class Connection
    ##
    # Retrieve an Edge Gateway :-)
    def get_edge_gateway(id, options = {})

      response, headers = get_edge_gateway_request(id)

      name        = response.css("EdgeGateway").attribute("name")
      name        = name.text unless name.nil?
      description = response.css("Description").first
      description = description.text unless description.nil?

      interfaces = []
      response.css("GatewayInterface").each do |interface_item|
        interface           = Hash.new {|h,k| h[k] = Array.new }
        interface[:name]    = interface_item.css('Name').nil? ? "UNKNOWN" : interface_item.css('Name').text
        interface[:type]    = interface_item.css('InterfaceType').nil? ? "UNKNOWN" : interface_item.css('InterfaceType').text
        interface[:ip]      = interface_item.css('IpAddress').nil? ? "UNKNOWN" : interface_item.css('IpAddress').text
        interface[:gateway] = interface_item.css('Gateway').nil? ? "UNKNOWN" : interface_item.css('Gateway').text
        interface[:netmask] = interface_item.css('Netmask').nil? ? "UNKNOWN" : interface_item.css('Netmask').text

        interface_item.css("Network[type='application/vnd.vmware.admin.network+xml']").each { |n|
          interface[:networks] <<  { n['name'] => n['href'].gsub(/.*\/network\//, "") }
        }

        interface_item.css("IpRange").each { |ipr|
          strtaddr = ipr.css("StartAddress").text
          endaddr  = ipr.css("EndAddress").text
          interface[:ipranges] << { :start => strtaddr, :end => endaddr }
        }
        interfaces << interface
      end

      firewall      = get_firewall_service_config response.css('FirewallService')
      nat           = get_nat_service_config response.css('NatService')
      load_balancer = get_load_balancer_service_config response.css('LoadBalancerService')

      gateway = { :id => id, :name => name, :description => description,
        :interfaces => interfaces,  :firewall => firewall, :nat => nat,
        :load_balancer => load_balancer }

      File.open('/tmp/gateway.yml', 'w') { |file| file.write(Psych.dump(gateway, :indentation => 3)) } if options[:save]
      gateway
    end

    ##
    # Update a named Virtual Server Pool's members.
    #
    #
    def update_virtual_server_pool_members(gateway_id, pool_name, new_members=[])
      # First retrieve the Edge Gateway configuration.
      params = {
          'method' => :get,
          'command' => "/admin/edgeGateway/#{gateway_id}"
      }
      response, headers = send_request(params)
      pool = response.at("Pool:contains('#{pool_name}')")
      raise ArgumentError.new("Did not find Pool '#{pool_name}' on Gateway ID: '#{gateway_id}'") if pool.nil?

      # Then make the necessary modifications. In this case simply patch the XML with the IPs of the new servers.
      number_of_ips = pool.css('Member IpAddress').length
      number_of_new_members = new_members.length
      if number_of_new_members > number_of_ips
        raise UnsupportedOperationError.new("You have provided more new pool member IPs (#{number_of_new_members}) than there are current pool members (#{number_of_ips})")
      end

      pool.css('Member IpAddress').each_with_index do |ip, index|
        ip.content = new_members[index]
      end

      task_id = update_gateway_service_config(gateway_id, response)
      task_id
    end

    ##
    # Update the firewall configuration based on user updates to the YAML
    # retrieved from a 'get_edge_gateway' call.
    #
    def update_firewall_config(gateway_yaml)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.FirewallService {
          xml.IsEnabled gateway_yaml[:firewall][:enabled?].to_s
          xml.DefaultAction "drop"
          xml.LogDefaultAction "false"
          gateway_yaml[:firewall][:rules].each do |rule|
            xml.FirewallRule {
              xml.Id rule[:id]
              xml.IsEnabled rule[:enabled?].to_s
              xml.MatchOnTranslate "false"
              xml.Description rule[:name]
              xml.Policy "allow"
              xml.Protocols {
                xml.Any "true" if rule[:protocol] == "any"
                xml.Icmp "true" if rule[:protocol] == "icmp"
                xml.Tcp "true" if rule[:protocol] == "tcp"
                xml.Udp "true" if rule[:protocol] == "udp"
              }
              xml.IcmpSubType(rule[:icmp_subtype]) if rule[:icmp_subtype]
              xml.Port "-1" # Please use only DestinationPortRange and SourcePortRange
              xml.DestinationPortRange rule[:destination][:port]
              xml.DestinationIp rule[:destination][:ip]
              xml.SourcePort "-1" # Please use only DestinationPortRange and SourcePortRange
              xml.SourcePortRange rule[:source][:port]
              xml.SourceIp rule[:source][:ip]
              xml.EnableLogging rule[:logging?].to_s
            }
          end
        }
      end
      response, headers = get_edge_gateway_request(gateway_yaml[:id])
      response.css('EdgeGatewayServiceConfiguration FirewallService').each do |node|
        node.replace builder.doc.root.to_xml
      end
      update_gateway_service_config(gateway_yaml[:id], response)
    end

    private

    def get_edge_gateway_request(id)
      params = {
          'method' => :get,
          'command' => "/admin/edgeGateway/#{id}"
      }

      return send_request(params)
    end

    ##
    # Parse the 'FirewallService' node into a Hash.
    # NOTES:
    #   - Protocols is translated into a single property. If it's possible to have multiple protocols this should change
    #   - For each 'FirewallRule' element we Nokogiri::XML::DocumentFragment.parse. This is due to an XPath/CSS issue in
    #     finding the correct IsEnabled element (because it's used throughout the rule XML).
    #
    def get_firewall_service_config(service_xml)

      return {} if service_xml.nil?
      xml = Nokogiri::XML::DocumentFragment.parse(service_xml)

      enabled = xml.xpath('./FirewallService/IsEnabled').text == "true" ? true : false

      rules = []
      xml.css('FirewallRule').each do |rule_xml|
        rule_xml = Nokogiri::XML::DocumentFragment.parse(rule_xml)
        rule = {}
        rule[:enabled?] = (!rule_xml.xpath('./FirewallRule/IsEnabled').nil? && rule_xml.xpath('./FirewallRule/IsEnabled').text == "true") ? true : false
        rule[:id] = rule_xml.css('Id').text
        rule[:name] = rule_xml.css('Description').text
        rule[:source] = { :ip => rule_xml.css('SourceIp').text, :port => rule_xml.css('SourcePortRange').text }
        rule[:destination] = { :ip => rule_xml.css('DestinationIp').text, :port => rule_xml.css('DestinationPortRange').text }
        rule[:logging?] = (!rule_xml.css('EnableLogging').nil? && rule_xml.css('EnableLogging').text == "true") ? true : false

        rule[:protocol] = "icmp" if rule_xml.at_css('Protocols Icmp')
        rule[:protocol] = "tcp" if rule_xml.at_css('Protocols Tcp')
        rule[:protocol] = "udp" if rule_xml.at_css('Protocols Udp')
        rule[:protocol] = "any" if rule_xml.at_css('Protocols Any')
        rules << rule
      end

      { :enabled? => enabled, :rules => rules }
    end

    ##
    # Parse the 'NatService' node into a Hash.
    #
    def get_nat_service_config(service_xml)

      return {} if service_xml.nil?
      xml = Nokogiri::XML::DocumentFragment.parse(service_xml)

      enabled = xml.xpath('./NatService/IsEnabled').text == "true" ? true : false

      rules = []
      xml.css('NatRule').each do |rule_xml|
        rule_xml = Nokogiri::XML::DocumentFragment.parse(rule_xml)
        rule = Hash.new {|h,k| h[k] = Array.new }
        rule[:enabled?] = (!rule_xml.xpath('./NatRule/IsEnabled').nil? && rule_xml.xpath('./NatRule/IsEnabled').text == "true") ? true : false
        rule[:type] = rule_xml.css('RuleType').text
        rule[:protocol] = rule_xml.css('GatewayNatRule Protocol').text
        rule[:original] = { :ip => rule_xml.css('GatewayNatRule OriginalIp').text, :port => rule_xml.css('GatewayNatRule OriginalPort').text }
        rule[:translated] = { :ip => rule_xml.css('GatewayNatRule TranslatedIp').text, :port => rule_xml.css('GatewayNatRule TranslatedPort').text }

        rule_xml.css("Interface[type='application/vnd.vmware.admin.network+xml']").each { |n|
          rule[:interfaces] << { n['name'] => n['href'].gsub(/.*\/network\//, "") }
        }
        rules << rule
      end

      { :enabled? => enabled, :rules => rules }
    end

    ##
    # Parse the 'LoadBalancerService' node into a Hash.
    #
    def get_load_balancer_service_config(service_xml)

      return {} if service_xml.nil?
      xml = Nokogiri::XML::DocumentFragment.parse(service_xml)

      enabled = xml.xpath('./LoadBalancerService/IsEnabled').text == "true" ? true : false

      pools = []
      xml.css('Pool').each do |rule_xml|
        rule_xml = Nokogiri::XML::DocumentFragment.parse(rule_xml)
        pool = Hash.new {|h,k| h[k] = Array.new }
        pool[:name] = rule_xml.css('Name').text
        pool[:description] = rule_xml.css('Description').text

        rule_xml.css("ServicePort").each { |p|
          pool[:service_ports] << {
            :enabled?     => ((!p.css('IsEnabled').nil? && p.css('IsEnabled').text == "true") ? true : false),
            :protocol     => p.css('Protocol').text,
            :algorithm    => p.css('Algorithm').text,
            :port         => p.css('Port').text,
            :health_check => {
                :port => p.css('HealthCheckPort').text,
                :mode => p.css('Mode').text,
                :uri  => p.css('Uri').text,
                :interval => p.css('Interval').text,
                :timeout  => p.css('Timeout').text,
                :health_threshold => p.css('HealthThreshold').text,
                :unhealth_threshold => p.css('UnhealthThreshold').text
            }
          }
        }
        pools << pool
      end

      vips = []
      xml.css('VirtualServer').each do |vip_xml|
        vip_xml = Nokogiri::XML::DocumentFragment.parse(vip_xml)
        vip = Hash.new {|h,k| h[k] = Array.new }
        vip[:enabled?] = (!vip_xml.xpath('./VirtualServer/IsEnabled').nil? && vip_xml.xpath('./VirtualServer/IsEnabled').text == "true") ? true : false
        vip[:logging?] = (!vip_xml.css('Logging').nil? && vip_xml.css('Logging').text == "true") ? true : false
        vip[:name] = vip_xml.css('Name').text
        vip[:description] = vip_xml.css('Description').text
        vip[:ipaddress] = vip_xml.css('IpAddress').text
        vip[:pool] = vip_xml.css('Pool').text

        vip_xml.css("Interface[type='application/vnd.vmware.admin.network+xml']").each { |n|
          vip[:interfaces] = {}
          vip[:interfaces] << { n['name'] => n['href'].gsub(/.*\/network\//, "") }
        }

        services = []
        vip_xml.css("ServiceProfile").each { |profile_xml|
          profile_xml = Nokogiri::XML::DocumentFragment.parse(profile_xml)
          service = {}
          service[:enabled?] = (!profile_xml.xpath('./ServiceProfile/IsEnabled').nil? && profile_xml.xpath('./ServiceProfile/IsEnabled').text == "true") ? true : false
          service[:protocol] = profile_xml.css('Protocol').text
          service[:port] = profile_xml.css('Port').text
          service[:persistence_method] = profile_xml.css('Persistence Method').text
          services << service
        }
        vip[:services] = services
        vips << vip
      end

      { :enabled? => enabled, :pools => pools, :virtual_servers => vips }
    end

    def update_gateway_service_config(gateway_id, update_xml)
      # TODO: Figure out the 'correct' way to extract a <EdgeGatewayServiceConfiguration /> document from the main document
      #
      # We cannot simply POST back the <EdgeGatewayServiceConfiguration /> that we extracted from the 'response' with
      # the required changes because that XML fragment is missing the necessary namespace declaration. We add that here:
      #
      post_doc = Nokogiri::XML::Document.parse(update_xml.at('EdgeGatewayServiceConfiguration').to_s)
      post_doc.root.add_namespace(nil, 'http://www.vmware.com/vcloud/v1.5')

      post_params = {
          "method" => :post,
          "command" => "/admin/edgeGateway/#{gateway_id}/action/configureServices"
      }
      post_response, post_headers = send_request(post_params, post_doc.to_xml,
                                                 'application/vnd.vmware.admin.edgeGatewayServiceConfiguration+xml')

      task = post_response.css("Task").first
      task_id = task["href"].gsub(/.*\/task\//, "")
      task_id
    end
  end
end