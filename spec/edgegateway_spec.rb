## Support for 1.8.x
unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end
##

require 'awesome_print'
require 'minitest/autorun'
require 'minitest/spec'
require 'webmock/minitest'
require 'yaml'
require_relative '../lib/vcloud-rest/connection'

describe VCloudClient::Connection do
  before do
    @args = {:host => 'https://testhost.local',
             :username => 'testuser',
             :password => 'testpass',
             :org => 'testorg',
             :api_version => "5.1"}

    @connection = VCloudClient::Connection.new(@args[:host], @args[:username],
                                               @args[:password], @args[:org], @args[:api_version])
  end

  describe "retrieving an Edge Gateway by ID" do
    before { @url = "https://testuser%40testorg:testpass@testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677" }

    it "should parse the response XML into a Hash object" do
      stub_request(:get, @url).
          to_return(:status => 200,
                    :headers => {:date=>"Fri, 10 Jan 2014 09:09:09 GMT", :content_type=>"application/vnd.vmware.admin.edgegateway+xml;version=5.1"},
                    :body => "<EdgeGateway xmlns=\"http://www.vmware.com/vcloud/v1.5\" status=\"1\" name=\"test-edge-gateway\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677\">
                                <Description>A Test Edge Gateway</Description>
                                <Configuration>
                                  <GatewayBackingConfig>full</GatewayBackingConfig>
                                  <GatewayInterfaces>
                                    <GatewayInterface>
                                      <Name>External</Name>
                                      <DisplayName>External</DisplayName>
                                      <Network type=\"application/vnd.vmware.admin.network+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/238676ef-b5db-437d-af2b-2f9e6736aebf\" />
                                      <InterfaceType>uplink</InterfaceType>
                                      <SubnetParticipation>
                                        <Gateway>192.168.33.1</Gateway>
                                        <Netmask>255.255.255.0</Netmask>
                                        <IpAddress>192.168.33.201</IpAddress>
                                        <IpRanges>
                                          <IpRange>
                                            <StartAddress>192.168.33.10</StartAddress>
                                            <EndAddress>192.168.15</EndAddress>
                                          </IpRange>
                                        </IpRanges>
                                      </SubnetParticipation>
                                      <ApplyRateLimit>false</ApplyRateLimit>
                                      <InRateLimit>100.0</InRateLimit>
                                      <OutRateLimit>100.0</OutRateLimit>
                                      <UseForDefaultRoute>true</UseForDefaultRoute>
                                    </GatewayInterface>
                                  </GatewayInterfaces>
                                  <EdgeGatewayServiceConfiguration>
                                    <FirewallService>
                                      <IsEnabled>true</IsEnabled>
                                      <DefaultAction>drop</DefaultAction>
                                      <LogDefaultAction>false</LogDefaultAction>
                                      <FirewallRule>
                                        <Id>1</Id>
                                        <IsEnabled>true</IsEnabled>
                                        <MatchOnTranslate>false</MatchOnTranslate>
                                        <Description>default-allow-any-any-icmp</Description>
                                        <Policy>allow</Policy>
                                        <Protocols>
                                          <Icmp>true</Icmp>
                                        </Protocols>
                                        <IcmpSubType>any</IcmpSubType>
                                        <Port>-1</Port>
                                        <DestinationPortRange>Any</DestinationPortRange>
                                        <DestinationIp>Any</DestinationIp>
                                        <SourcePort>-1</SourcePort>
                                        <SourcePortRange>Any</SourcePortRange>
                                        <SourceIp>Any</SourceIp>
                                        <EnableLogging>false</EnableLogging>
                                      </FirewallRule>
                                    </FirewallService>
                                    <NatService>
                                      <IsEnabled>false</IsEnabled>
                                      <NatRule>
                                        <RuleType>DNAT</RuleType>
                                        <IsEnabled>true</IsEnabled>
                                        <Id>65537</Id>
                                        <GatewayNatRule>
                                          <Interface type=\"application/vnd.vmware.admin.network+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/238676ef-b5db-437d-af2b-2f9e6736aebf\" />
                                          <OriginalIp>192.182.33.15</OriginalIp>
                                          <OriginalPort>any</OriginalPort>
                                          <TranslatedIp>10.72.64.34</TranslatedIp>
                                          <TranslatedPort>any</TranslatedPort>
                                          <Protocol>tcpudp</Protocol>
                                        </GatewayNatRule>
                                      </NatRule>
                                    </NatService>
                                    <LoadBalancerService>
                                      <IsEnabled>false</IsEnabled>
                                      <Pool>
                                        <Name>test_pool</Name>
                                        <ServicePort>
                                          <IsEnabled>true</IsEnabled>
                                          <Protocol>HTTP</Protocol>
                                          <Algorithm>ROUND_ROBIN</Algorithm>
                                          <Port>8080</Port>
                                          <HealthCheckPort>8080</HealthCheckPort>
                                          <HealthCheck>
                                            <Mode>HTTP</Mode>
                                            <Uri>/</Uri>
                                            <HealthThreshold>2</HealthThreshold>
                                            <UnhealthThreshold>3</UnhealthThreshold>
                                            <Interval>5</Interval>
                                            <Timeout>15</Timeout>
                                          </HealthCheck>
                                        </ServicePort>
                                        <ServicePort>
                                          <IsEnabled>true</IsEnabled>
                                          <Protocol>HTTPS</Protocol>
                                          <Algorithm>ROUND_ROBIN</Algorithm>
                                          <Port>8443</Port>
                                          <HealthCheckPort>8443</HealthCheckPort>
                                          <HealthCheck>
                                            <Mode>SSL</Mode>
                                            <HealthThreshold>2</HealthThreshold>
                                            <UnhealthThreshold>3</UnhealthThreshold>
                                            <Interval>5</Interval>
                                            <Timeout>15</Timeout>
                                          </HealthCheck>
                                        </ServicePort>
                                        <Member>
                                          <IpAddress>10.72.64.46</IpAddress>
                                          <Weight>1</Weight>
                                          <ServicePort>
                                            <Protocol>HTTP</Protocol>
                                            <Port>8080</Port>
                                            <HealthCheckPort>8080</HealthCheckPort>
                                          </ServicePort>
                                          <ServicePort>
                                            <Protocol>HTTPS</Protocol>
                                            <Port>8443</Port>
                                            <HealthCheckPort>8443</HealthCheckPort>
                                          </ServicePort>
                                          <ServicePort>
                                            <Protocol>TCP</Protocol>
                                            <Port />
                                            <HealthCheckPort />
                                          </ServicePort>
                                        </Member>
                                        <Member>
                                          <IpAddress>10.72.64.48</IpAddress>
                                          <Weight>1</Weight>
                                          <ServicePort>
                                            <Protocol>HTTP</Protocol>
                                            <Port>8080</Port>
                                            <HealthCheckPort>8080</HealthCheckPort>
                                          </ServicePort>
                                          <ServicePort>
                                            <Protocol>HTTPS</Protocol>
                                            <Port>8443</Port>
                                            <HealthCheckPort>8443</HealthCheckPort>
                                          </ServicePort>
                                          <ServicePort>
                                            <Protocol>TCP</Protocol>
                                            <Port />
                                            <HealthCheckPort />
                                          </ServicePort>
                                        </Member>
                                        <Operational>true</Operational>
                                      </Pool>
                                      <VirtualServer>
                                        <IsEnabled>true</IsEnabled>
                                        <Name>test_vip</Name>
                                        <Interface type=\"application/vnd.vmware.vcloud.orgVdcNetwork+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/238676ef-b5db-437d-af2b-2f9e6736aebf\" />
                                        <IpAddress>192.168.33.11</IpAddress>
                                        <ServiceProfile>
                                          <IsEnabled>true</IsEnabled>
                                          <Protocol>HTTP</Protocol>
                                          <Port>80</Port>
                                          <Persistence>
                                            <Method />
                                          </Persistence>
                                        </ServiceProfile>
                                        <ServiceProfile>
                                          <IsEnabled>true</IsEnabled>
                                          <Protocol>HTTPS</Protocol>
                                          <Port>443</Port>
                                          <Persistence>
                                            <Method />
                                          </Persistence>
                                        </ServiceProfile>
                                        <ServiceProfile>
                                          <IsEnabled>false</IsEnabled>
                                          <Protocol>TCP</Protocol>
                                          <Port />
                                          <Persistence>
                                            <Method />
                                          </Persistence>
                                        </ServiceProfile>
                                        <Logging>false</Logging>
                                        <Pool>test_pool</Pool>
                                      </VirtualServer>
                                    </LoadBalancerService>
                                  </EdgeGatewayServiceConfiguration>
                                  <HaEnabled>true</HaEnabled>
                                  <UseDefaultRouteForDnsRelay>false</UseDefaultRouteForDnsRelay>
                                </Configuration>
                              </EdgeGateway>")

      egw = @connection.get_edge_gateway '95d60018-1752-41f3-ba77-11223344556677', :save => true
      egw[:interfaces].count.must_equal 1
      egw[:firewall][:rules].count.must_equal 1
      egw[:firewall][:rules][0][:id].must_equal "1"
      egw[:firewall][:rules][0][:name].must_equal "default-allow-any-any-icmp"

      # Ensure that the 'IsEnabled' elements for NAT service/rules are being parsed correctly
      egw[:nat][:enabled?].must_equal false
      egw[:nat][:rules][0][:enabled?].must_equal true
      egw[:nat][:rules][0][:original][:ip].must_equal "192.182.33.15"
    end
  end
end

