module VCloudClient
  class Connection
    ##
    # Fetch details about a given vdc:
    # - description
    # - vapps
    # - networks
    def get_vdc(vdcId)
      params = {
        'method' => :get,
        'command' => "/vdc/#{vdcId}"
      }

      response, headers = send_request(params)

      name = response.css("Vdc").attribute("name")
      name = name.text unless name.nil?

      description = response.css("Description").first
      description = description.text unless description.nil?

      vapps = {}
      response.css("ResourceEntity[type='application/vnd.vmware.vcloud.vApp+xml']").each do |item|
        vapps[item['name']] = item['href'].gsub(/.*\/vApp\/vapp\-/, "")
      end

      networks = {}
      response.css("Network[type='application/vnd.vmware.vcloud.network+xml']").each do |item|
        networks[item['name']] = item['href'].gsub(/.*\/network\//, "")
      end

      #
      # Also retrieve the VDC's Edge Gateway objects.
      # It is clearly open to debate whether this should be here or whether it should
      # be a separate call. Personally, I like it here.
      #
      gateways = {}
      egw_params = {
          'method' => :get,
          'command' => "/admin/vdc/#{vdcId}/edgeGateways"
      }
      query_response, query_headers = send_request(egw_params)
      query_response.css('QueryResultRecords EdgeGatewayRecord').each do |gateway_record|
        gateways[gateway_record['name']] = gateway_record['href'].gsub(/.*\/edgeGateway\//, "")
      end

      { :id => vdcId, :name => name, :description => description,
        :vapps => vapps, :networks => networks, :gateways => gateways }
    end

    ##
    # Friendly helper method to fetch a Organization VDC Id by name
    # - Organization object
    # - Organization VDC Name
    def get_vdc_id_by_name(organization, vdcName)
      result = nil

      organization[:vdcs].each do |vdc|
        if vdc[0].downcase == vdcName.downcase
          result = vdc[1]
        end
      end

      result
    end

    ##
    # Friendly helper method to fetch a Organization VDC by name
    # - Organization object
    # - Organization VDC Name
    def get_vdc_by_name(organization, vdcName)
      result = nil

      organization[:vdcs].each do |vdc|
        if vdc[0].downcase == vdcName.downcase
          result = get_vdc(vdc[1])
        end
      end

      result
    end
  end
end