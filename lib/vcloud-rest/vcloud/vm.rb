module VCloudClient
  class Connection
    ##
    # Retrieve information (i.e., memory and CPUs)
    def get_vm_info(vmid)
      params = {
        'method' => :get,
        'command' => "/vApp/vm-#{vmid}/virtualHardwareSection"
      }

      response, headers = send_request(params)

      result = {}
      response.css("ovf|Item [vcloud|href]").each do |item|
        item_name = item.attribute('href').text.gsub(/.*\/vApp\/vm\-(\w+(-?))+\/virtualHardwareSection\//, "")
        name = item.css("rasd|ElementName")
        name = name.text unless name.nil?

        description = item.css("rasd|Description")
        description = description.text unless description.nil?

        result[item_name] = {
          :name => name,
          :description => description
        }
      end

      result
    end

    ##
    # Get metadata for the VM specified by 'vmid'.
    #
    def get_vm_metadata(vmid)
      params = {
          'method' => :get,
          'command' => "/vApp/vm-#{vmid}/metadata"
      }
      response, headers = send_request(params)

      tags = {}
      response.css("MetadataEntry").each do |tag|
        key = tag.css("Key").first
        key = key.text unless key.nil?
        val = tag.css("TypedValue Value").first
        val = val.text unless val.nil?
        tags[key] = val
      end
      tags
    end

    ##
    # Add a metadata tag to the VM specified by 'vmid'.
    #
    #  - Currently will only add tags as String type.
    #
    def set_vm_metadata(vmid, key, value)
      params = {
          'method' => :put,
          'command' => "/vApp/vm-#{vmid}/metadata/#{URI.escape(key)}"
      }

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.MetadataValue(
            "xmlns" => "http://www.vmware.com/vcloud/v1.5",
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") {
          xml.TypedValue("xsi:type" => "MetadataStringValue") {
            xml.Value value
          }
        }
      end

      response, headers = send_request(params, builder.to_xml, "application/vnd.vmware.vcloud.metadata.value+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Retrieve information about Disks
    def get_vm_disk_info(vmid)
      response, headers = __get_disk_info(vmid)

      parentId = get_scsi_parent_id(response)
      @logger.warn "parentId : #{parentId}."
      
      disks = []
      response.css("Item").each do |entry|
        # Pick only entries with node "HostResource"
        resource = entry.css("rasd|HostResource").first
        next unless resource

        name = entry.css("rasd|ElementName").first
        name = name.text unless name.nil?
        capacity = resource.attribute("capacity").text

        disks << {
          :name => name,
          :capacity => "#{capacity} MB"
        }
      end
      disks
    end

    ##
    # Set information about Disks
    #
    # Disks can be added, deleted or modified
    def set_vm_disk_info(vmid, disk_info={})
      get_response, headers = __get_disk_info(vmid)

      if disk_info[:add]
        data = add_disk(get_response, disk_info)
      else
        data = edit_disk(get_response, disk_info)
      end

      params = {
        'method' => :put,
        'command' => "/vApp/vm-#{vmid}/virtualHardwareSection/disks"
      }
      put_response, headers = send_request(params, data, "application/vnd.vmware.vcloud.rasdItemsList+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Set VM CPUs
    def set_vm_cpus(vmid, cpu_number)
      params = {
        'method' => :get,
        'command' => "/vApp/vm-#{vmid}/virtualHardwareSection/cpu"
      }

      get_response, headers = send_request(params)

      # Change attributes from the previous invocation
      get_response.css("rasd|ElementName").first.content = "#{cpu_number} virtual CPU(s)"
      get_response.css("rasd|VirtualQuantity").first.content = cpu_number

      params['method'] = :put
      put_response, headers = send_request(params, get_response.to_xml, "application/vnd.vmware.vcloud.rasdItem+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Set VM RAM
    def set_vm_ram(vmid, memory_size)
      params = {
        'method' => :get,
        'command' => "/vApp/vm-#{vmid}/virtualHardwareSection/memory"
      }

      get_response, headers = send_request(params)

      # Change attributes from the previous invocation
      get_response.css("rasd|ElementName").first.content = "#{memory_size} MB of memory"
      get_response.css("rasd|VirtualQuantity").first.content = memory_size

      params['method'] = :put
      put_response, headers = send_request(params, get_response.to_xml, "application/vnd.vmware.vcloud.rasdItem+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Edit VM Network Config
    #
    # Retrieve the existing network config section and edit it
    # to ensure settings are not lost
    def edit_vm_network(vmId, network, config={})
      params = {
        'method' => :get,
        'command' => "/vApp/vm-#{vmId}/networkConnectionSection"
      }

      netconfig_response, headers = send_request(params)

      picked_network = netconfig_response.css("NetworkConnection").select do |net|
        net.attribute('network').text == network[:name]
      end.first

      raise WrongItemIDError, "Network named #{network[:name]} not found." unless picked_network

      if config[:ip_allocation_mode]
        node = picked_network.css('IpAddressAllocationMode').first
        node.content = config[:ip_allocation_mode]
      end

      if config[:network_index]
        node = picked_network.css('NetworkConnectionIndex').first
        node.content = config[:network_index]
      end

      if config[:is_connected]
        node = picked_network.css('IsConnected').first
        node.content = config[:is_connected]
      end

      if config[:ip]
        node = picked_network.css('IpAddress').first
        node.content = config[:ip]
      end

      params = {
        'method' => :put,
        'command' => "/vApp/vm-#{vmId}/networkConnectionSection"
      }

      response, headers = send_request(params, netconfig_response.to_xml, "application/vnd.vmware.vcloud.networkConnectionSection+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Add a new network to a VM
    def add_vm_network(vmId, network, config={})
      params = {
        'method' => :get,
        'command' => "/vApp/vm-#{vmId}/networkConnectionSection"
      }

      netconfig_response, headers = send_request(params)

      parent_section = netconfig_response.css('NetworkConnectionSection').first

      # For some reasons these elements must be removed
      netconfig_response.css("Link").each {|n| n.remove}

      networks_count = netconfig_response.css('NetworkConnection').count

      new_network = Nokogiri::XML::Node.new "NetworkConnection", parent_section
      new_network["network"] = network[:name]
      new_network["needsCustomization"] = true

      idx_node = Nokogiri::XML::Node.new "NetworkConnectionIndex", new_network
      idx_node.content = config[:network_index] || networks_count
      new_network.add_child(idx_node)

      is_connected_node = Nokogiri::XML::Node.new "IsConnected", new_network
      is_connected_node.content = config[:is_connected] || true
      new_network.add_child(is_connected_node)

      allocation_node = Nokogiri::XML::Node.new "IpAddressAllocationMode", new_network
      allocation_node.content = config[:ip_allocation_mode] || "POOL"
      new_network.add_child(allocation_node)

      if config[:ip]
        ip_node = Nokogiri::XML::Node.new "IpAddress", new_network
        ip_node.content = config[:ip]
        new_network.add_child(ip_node)
      end

      parent_section.add_child(new_network)

      params = {
        'method' => :put,
        'command' => "/vApp/vm-#{vmId}/networkConnectionSection"
      }

      put_response, headers = send_request(params, netconfig_response.to_xml, "application/vnd.vmware.vcloud.networkConnectionSection+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Remove an existing network
    def delete_vm_network(vmId, network)
      params = {
        'method' => :get,
        'command' => "/vApp/vm-#{vmId}/networkConnectionSection"
      }

      netconfig_response, headers = send_request(params)

      picked_network = netconfig_response.css("NetworkConnection").select do |net|
        net.attribute('network').text == network[:name]
      end.first

      raise WrongItemIDError, "Network #{network[:name]} not found on this VM." unless picked_network

      picked_network.remove

      params = {
        'method' => :put,
        'command' => "/vApp/vm-#{vmId}/networkConnectionSection"
      }

      put_response, headers = send_request(params, netconfig_response.to_xml, "application/vnd.vmware.vcloud.networkConnectionSection+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Set VM Network Config
    #
    # DEPRECATED: use set_vm_network
    def set_vm_network_config(vmid, network_name, config={})
      @logger.warn 'DEPRECATION WARNING: use [add,delete,edit]_vm_network instead.'

      builder = Nokogiri::XML::Builder.new do |xml|
      xml.NetworkConnectionSection(
        "xmlns" => "http://www.vmware.com/vcloud/v1.5",
        "xmlns:ovf" => "http://schemas.dmtf.org/ovf/envelope/1") {
        xml['ovf'].Info "VM Network configuration"
        xml.PrimaryNetworkConnectionIndex(config[:primary_index] || 0)
        xml.NetworkConnection("network" => network_name, "needsCustomization" => true) {
          xml.NetworkConnectionIndex(config[:network_index] || 0)
          xml.IpAddress config[:ip] if config[:ip]
          xml.IsConnected(config[:is_connected] || true)
          xml.IpAddressAllocationMode config[:ip_allocation_mode] if config[:ip_allocation_mode]
        }
      }
      end

      params = {
        'method' => :put,
        'command' => "/vApp/vm-#{vmid}/networkConnectionSection"
      }

      response, headers = send_request(params, builder.to_xml, "application/vnd.vmware.vcloud.networkConnectionSection+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end


    ##
    # Set VM Guest Customization Config
    def set_vm_guest_customization(vmid, computer_name, config={})
      builder = Nokogiri::XML::Builder.new do |xml|
      xml.GuestCustomizationSection(
        "xmlns" => "http://www.vmware.com/vcloud/v1.5",
        "xmlns:ovf" => "http://schemas.dmtf.org/ovf/envelope/1") {
          xml['ovf'].Info "VM Guest Customization configuration"
          xml.Enabled config[:enabled] if config[:enabled]
          xml.AdminPasswordEnabled config[:admin_passwd_enabled] if config[:admin_passwd_enabled]
          xml.AdminPassword config[:admin_passwd] if config[:admin_passwd]
          xml.CustomizationScript config[:customization_script] if config[:customization_script]
          xml.ComputerName computer_name
      }
      end

      params = {
        'method' => :put,
        'command' => "/vApp/vm-#{vmid}/guestCustomizationSection"
      }

      response, headers = send_request(params, builder.to_xml, "application/vnd.vmware.vcloud.guestCustomizationSection+xml")

      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Force a guest customization
    def force_customization_vm(vmId)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.DeployVAppParams(
          "xmlns" => "http://www.vmware.com/vcloud/v1.5",
          "forceCustomization" => "true")
      end

      params = {
        "method" => :post,
        "command" => "/vApp/vm-#{vmId}/action/deploy"
      }

      response, headers = send_request(params, builder.to_xml, "application/vnd.vmware.vcloud.deployVAppParams+xml")
      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    def rename_vm(vmId, name)
      params = {
        'method' => :get,
        'command' => "/vApp/vm-#{vmId}"
      }

      response, headers = send_request(params)
      response.css('Vm').attribute("name").content = name

      params['method'] = :put
      response, headers = send_request(params, response.to_xml,
                                    "application/vnd.vmware.vcloud.vm+xml")
      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Fetch details about a given VM
    def get_vm(vmId)
      params = {
        'method' => :get,
        'command' => "/vApp/vm-#{vmId}"
      }

      response, headers = send_request(params)

      vm_name = response.css('Vm').attribute("name")
      vm_name = vm_name.text unless vm_name.nil?

      status = convert_vapp_status(response.css('Vm').attribute("status").text)

      os_desc = response.css('ovf|OperatingSystemSection ovf|Description').first.text

      networks = {}
      response.css('NetworkConnection').each do |network|
        ip = network.css('IpAddress').first
        ip = ip.text if ip

        external_ip = network.css('ExternalIpAddress').first
        external_ip = external_ip.text if external_ip

        networks[network['network']] = {
          :index => network.css('NetworkConnectionIndex').first.text,
          :ip => ip,
          :external_ip => external_ip,
          :is_connected => network.css('IsConnected').first.text,
          :mac_address => network.css('MACAddress').first.text,
          :ip_allocation_mode => network.css('IpAddressAllocationMode').first.text
        }
      end

      admin_password = response.css('GuestCustomizationSection AdminPassword').first
      admin_password = admin_password.text if admin_password

      guest_customizations = {
        :enabled => response.css('GuestCustomizationSection Enabled').first.text,
        :admin_passwd_enabled => response.css('GuestCustomizationSection AdminPasswordEnabled').first.text,
        :admin_passwd_auto => response.css('GuestCustomizationSection AdminPasswordAuto').first.text,
        :admin_passwd => admin_password,
        :reset_passwd_required => response.css('GuestCustomizationSection ResetPasswordRequired').first.text,
        :computer_name => response.css('GuestCustomizationSection ComputerName').first.text
      }

      { :id => vmId,
        :vm_name => vm_name, :os_desc => os_desc, :networks => networks,
        :guest_customizations => guest_customizations, :status => status
      }
    end

    ##
    # Friendly helper method to fetch a vApp by name
    # - Organization object
    # - Organization VDC Name
    # - vApp Name
    # - VM Name
    def get_vm_by_name(organization, vdcName, vAppName, vmName)
      result = nil

      get_vapp_by_name(organization, vdcName, vAppName)[:vms_hash].each do |key, values|
        if key.downcase == vmName.downcase
          result = get_vm(values[:id])
        end
      end

      result
    end


    def set_vm_hostname(vmId, hostname)
      params = {
          'method' => :get,
          'command' => "/vApp/vm-#{vmId}"
      }

      response, headers = send_request(params)

      response.css('GuestCustomizationSection ComputerName').each do |node|
        node.content = hostname.to_s
      end

      customisation = Nokogiri::XML::Document.parse(response.at('GuestCustomizationSection').to_s)
      customisation.root.add_namespace(nil, 'http://www.vmware.com/vcloud/v1.5')
      customisation.root.add_namespace('ovf', 'http://schemas.dmtf.org/ovf/envelope/1')

      put_params = {
          "method" => :put,
          "command" => "/vApp/vm-#{vmId}/guestCustomizationSection"
      }
      put_response, put_headers = send_request(put_params, customisation.to_xml,
                                                 'application/vnd.vmware.vcloud.guestCustomizationSection+xml')

      task = put_response.css("Task").first
      task_id = task["href"].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Shutdown a given vm
    def poweroff_vm(vmId)
      builder = Nokogiri::XML::Builder.new do |xml|
      xml.UndeployVAppParams(
        "xmlns" => "http://www.vmware.com/vcloud/v1.5") {
        xml.UndeployPowerAction 'powerOff'
      }
      end

      params = {
        'method' => :post,
        'command' => "/vApp/vm-#{vmId}/action/undeploy"
      }

      response, headers = send_request(params, builder.to_xml,
                      "application/vnd.vmware.vcloud.undeployVAppParams+xml")
      task_id = headers[:location].gsub(/.*\/task\//, "")
      task_id
    end

    ##
    # Suspend a given vm
    def suspend_vm(vmId)
      power_action(vmId, 'suspend', :vm)
    end

    ##
    # reboot a given vm
    # This will basically initial a guest OS reboot, and will only work if
    # VMware-tools are installed on the underlying VMs.
    # vShield Edge devices are not affected
    def reboot_vm(vmId)
      power_action(vmId, 'reboot', :vm)
    end

    ##
    # reset a given vm
    def reset_vm(vmId)
      power_action(vmId, 'reset', :vm)
    end

    ##
    # Boot a given vm
    def poweron_vm(vmId)
      power_action(vmId, 'powerOn', :vm)
    end

    ##
    # Create a new vm snapshot (overwrites any existing)
    def create_vm_snapshot(vmId, description="New Snapshot")
      create_snapshot_action(vmId, description, :vm)
    end

    ##
    # Revert to an existing snapshot
    def revert_vm_snapshot(vmId)
      revert_snapshot_action(vmId, :vm)
    end


    private
      def add_disk(source_xml, disk_info)
        disks_count = source_xml.css("Item").css("rasd|HostResource").count
        
        # get the hard disk controller parent Id, bit crude but better than hard coded as now
        parentId = get_scsi_parent_id(source_xml)

        # FIXME: This is a hack, but dealing with nokogiri APIs can be quite
        # frustrating sometimes...
        sibling = source_xml.css("Item").first
        new_disk = Nokogiri::XML::Node.new "PLACEHOLDER", sibling.parent
        sibling.add_next_sibling(new_disk)
        result = source_xml.to_xml

        result.gsub("<PLACEHOLDER/>", """
          <Item>
            <rasd:AddressOnParent>#{disks_count}</rasd:AddressOnParent>
            <rasd:Description>Hard disk</rasd:Description>
            <rasd:ElementName>Hard disk #{disks_count + 1}</rasd:ElementName>
            <rasd:HostResource
                  xmlns:ns12=\"http://www.vmware.com/vcloud/v1.5\"
                  ns12:capacity=\"#{disk_info[:disk_size]}\"
                  ns12:busSubType=\"lsilogic\"
                  ns12:busType=\"6\"/>
            <rasd:InstanceID>200#{disks_count}</rasd:InstanceID>
            <rasd:Parent>#{parentId}</rasd:Parent>
            <rasd:ResourceType>17</rasd:ResourceType>
          </Item>""")
      end

      def edit_disk(source_xml, disk_info)
        changed = false

        source_xml.css("Item").each do |entry|
          # Pick only entries with node "HostResource"
          resource = entry.css("rasd|HostResource").first
          next unless resource

          name = entry.css("rasd|ElementName").first
          name = name.text unless name.nil?
          next unless name == disk_info[:disk_name]

          changed = true

          if disk_info[:delete]
            entry.remove
          else
            # Set disk size
            resource.attribute("capacity").content = disk_info[:disk_size]
          end
          break
        end

        unless changed
          @logger.warn "Disk #{disk_info[:disk_name]} not found."
          raise WrongItemIDError, "Disk #{disk_info[:disk_name]} not found."
        end
        source_xml.to_xml
      end

      def get_scsi_parent_id(source_xml)
        instanceId = ""
        source_xml.css("Item").each do |entry|
          resourceType = entry.css("rasd|ResourceType").first
          resourceSubType = entry.css("rasd|ResourceSubType").first
          
          # If there is more than 1, might have to filter on resourceSubType too
          next unless resourceType.text == "6"

          instanceId = entry.css("rasd|InstanceID").first.text
          break
        end
        instanceId
      end
      
      def __get_disk_info(vmid)
        params = {
          'method' => :get,
          'command' => "/vApp/vm-#{vmid}/virtualHardwareSection/disks"
        }

        send_request(params)
      end
      
  end
end