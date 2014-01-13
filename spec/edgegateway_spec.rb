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

  describe "getting edge gateway" do
    before { @url = "https://testuser%40testorg:testpass@testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677" }

    it "should print a load of XML" do
      stub_request(:get, @url).
          to_return(:status => 200,
                    :headers => {:date=>"Fri, 10 Jan 2014 09:09:09 GMT", :content_type=>"application/vnd.vmware.admin.edgegateway+xml;version=5.1"},
                    :body => "
<EdgeGateway xmlns=\"http://www.vmware.com/vcloud/v1.5\" status=\"1\" name=\"test-edge-gateway\" id=\"urn:vcloud:gateway:95d60018-1752-41f3-ba77-11223344556677\" type=\"application/vnd.vmware.admin.edgeGateway+xml\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.vmware.com/vcloud/v1.5 http://testhost.local/api/v1.5/schema/master.xsd\">
  <Link rel=\"up\" type=\"application/vnd.vmware.vcloud.vdc+xml\" href=\"https://testhost.local/api/vdc/47dea0c7-f6c2-41b7-b270-a80216f924c3\" /> 
  <Link rel=\"edgeGateway:redeplo\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/redeploy\" /> 
  <Link rel=\"edgeGateway:configureServices\" type=\"application/vnd.vmware.admin.edgeGatewayServiceConfiguration+xml\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/configureServices\" /> 
  <Link rel=\"edgeGateway:reapplyServices\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/reapplyServices\" /> 
  <Link rel=\"edgeGateway:syncSyslogSettings\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/syncSyslogServerSettings\" /> 
  <Description>A Test Edge Gateway</Description>
  <Configuration> 
    <GatewayBackingConfig>full</GatewayBackingConfig> 
    <GatewayInterfaces> 
      <GatewayInterface> 
        <Name>BE-10.76.64.33-27</Name> 
        <DisplayName>BE-10.76.64.33-27</DisplayName> 
        <Network type=\"application/vnd.vmware.admin.network+xml\" name=\"BE-10.76.64.33-27\" href=\"https://testhost.local/api/admin/network/bee59968-9c77-4fd1-b845-34411564540a\" /> 
        <InterfaceType>internal</InterfaceType> 
        <SubnetParticipation> 
          <Gateway>10.76.64.33</Gateway> 
          <Netmask>255.255.255.224</Netmask> 
          <IpAddress>10.76.64.33</IpAddress> 
        </SubnetParticipation> 
        <ApplyRateLimit>false</ApplyRateLimit> 
        <UseForDefaultRoute>false</UseForDefaultRoute> 
      </GatewayInterface> 
      <GatewayInterface> 
        <Name>FE-10.72.64.33-27</Name> 
        <DisplayName>FE-10.72.64.33-27</DisplayName> 
        <Network type=\"application/vnd.vmware.admin.network+xml\" name=\"FE-10.72.64.33-27\" href=\"https://testhost.local/api/admin/network/5c702804-7028-43d7-8ef3-cbda716ccab8\" /> 
        <InterfaceType>internal</InterfaceType> 
        <SubnetParticipation> 
          <Gateway>10.72.64.33</Gateway> 
          <Netmask>255.255.255.224</Netmask> 
          <IpAddress>10.72.64.33</IpAddress> 
        </SubnetParticipation> 
        <ApplyRateLimit>false</ApplyRateLimit> 
        <UseForDefaultRoute>false</UseForDefaultRoute> 
      </GatewayInterface> 
      <GatewayInterface> 
        <Name>External</Name> 
        <DisplayName>External</DisplayName> 
        <Network type=\"application/vnd.vmware.admin.network+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/238676ef-b5db-437d-af2b-2f9e6736aebf\" /> 
        <InterfaceType>uplink</InterfaceType> 
        <SubnetParticipation> 
          <Gateway>159.182.33.1</Gateway> 
          <Netmask>255.255.255.0</Netmask> 
          <IpAddress>159.182.33.201</IpAddress> 
          <IpRanges> 
            <IpRange> 
              <StartAddress>159.182.33.10</StartAddress> 
              <EndAddress>159.182.33.15</EndAddress> 
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
        <FirewallRule> 
          <Id>2</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>allow-http-hosting</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>80</Port> 
          <DestinationPortRange>80</DestinationPortRange> 
          <DestinationIp>10.76.64.32/27</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>Any</SourceIp> 
          <EnableLogging>true</EnableLogging> 
        </FirewallRule> 
        <FirewallRule> 
          <Id>3</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>allow-https-hosting</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>443</Port> 
          <DestinationPortRange>443</DestinationPortRange> 
          <DestinationIp>10.76.64.32/27</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>Any</SourceIp> 
          <EnableLogging>true</EnableLogging> 
        </FirewallRule> 
        <FirewallRule> 
          <Id>4</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>default-allow-external-internal-ssh</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>22</Port> 
          <DestinationPortRange>22</DestinationPortRange> 
          <DestinationIp>internal</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>external</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule> 
        <FirewallRule> 
          <Id>5</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>default-allow-external-internal-rdp</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>3389</Port> 
          <DestinationPortRange>3389</DestinationPortRange> 
          <DestinationIp>internal</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>Any</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule> 
        <FirewallRule> 
          <Id>6</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>allow-jenkins-webapp</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>8080</Port> 
          <DestinationPortRange>8080</DestinationPortRange> 
          <DestinationIp>10.72.64.34</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>external</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule> 
        <FirewallRule> 
          <Id>7</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>Default internal ssh</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>22</Port> 
          <DestinationPortRange>22</DestinationPortRange> 
          <DestinationIp>internal</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>internal</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule>
        <FirewallRule> 
          <Id>8</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>allow-https-mystack-dev</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>443</Port> 
          <DestinationPortRange>443</DestinationPortRange> 
          <DestinationIp>159.182.33.11</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>external</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule> 
        <FirewallRule> 
          <Id>9</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>allow-https-mystack-test</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>443</Port> 
          <DestinationPortRange>443</DestinationPortRange> 
          <DestinationIp>159.182.33.12</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>external</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule>
        <FirewallRule> 
          <Id>10</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>allow-http-mystack-dev</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
          </Protocols> 
          <Port>80</Port> 
          <DestinationPortRange>80</DestinationPortRange> 
          <DestinationIp>159.182.33.11</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>external</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule> 
        <FirewallRule> 
          <Id>11</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>allow-ldap-outbound</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
            <Udp>true</Udp> 
          </Protocols> 
          <Port>389</Port> 
          <DestinationPortRange>389</DestinationPortRange> 
          <DestinationIp>Any</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>internal</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule> 
        <FirewallRule> 
          <Id>12</Id>
          <IsEnabled>true</IsEnabled> 
          <MatchOnTranslate>false</MatchOnTranslate> 
          <Description>allow-ldaps-outbound</Description> 
          <Policy>allow</Policy> 
          <Protocols> 
            <Tcp>true</Tcp> 
            <Udp>true</Udp> 
          </Protocols> 
          <Port>636</Port> 
          <DestinationPortRange>636</DestinationPortRange> 
          <DestinationIp>Any</DestinationIp> 
          <SourcePort>-1</SourcePort> 
          <SourcePortRange>Any</SourcePortRange> 
          <SourceIp>internal</SourceIp> 
          <EnableLogging>false</EnableLogging> 
        </FirewallRule>
      </FirewallService> 
      <NatService> 
        <IsEnabled>true</IsEnabled> 
        <NatRule> 
          <RuleType>DNAT</RuleType> 
          <IsEnabled>true</IsEnabled> 
          <Id>65537</Id> 
          <GatewayNatRule> 
            <Interface type=\"application/vnd.vmware.admin.network+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/238676ef-b5db-437d-af2b-2f9e6736aebf\" /> 
            <OriginalIp>159.182.33.15</OriginalIp> 
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
          <Name>mystack-dev</Name> 
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
          <ServicePort> 
            <IsEnabled>false</IsEnabled> 
            <Protocol>TCP</Protocol> 
            <Algorithm>ROUND_ROBIN</Algorithm> 
            <Port /> 
            <HealthCheckPort /> 
            <HealthCheck> 
              <Mode>TCP</Mode> 
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
        <Pool> 
          <Name>mystack-test</Name> 
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
          <ServicePort> 
            <IsEnabled>false</IsEnabled> 
            <Protocol>TCP</Protocol> 
            <Algorithm>ROUND_ROBIN</Algorithm> 
            <Port /> 
            <HealthCheckPort /> 
            <HealthCheck> 
              <Mode>TCP</Mode> 
              <HealthThreshold>2</HealthThreshold> 
              <UnhealthThreshold>3</UnhealthThreshold> 
              <Interval>5</Interval> 
              <Timeout>15</Timeout> 
            </HealthCheck> 
          </ServicePort> 
          <Member> 
            <IpAddress>10.72.64.55</IpAddress> 
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
            <IpAddress>10.72.64.56</IpAddress> 
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
          <Name>mystack-dev-vip</Name> 
          <Interface type=\"application/vnd.vmware.vcloud.orgVdcNetwork+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/238676ef-b5db-437d-af2b-2f9e6736aebf\" /> 
          <IpAddress>159.182.33.11</IpAddress> 
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
          <Pool>mystack-dev</Pool> 
        </VirtualServer> 
        <VirtualServer> 
          <IsEnabled>true</IsEnabled> 
          <Name>mystack-test-vip</Name> 
          <Interface type=\"application/vnd.vmware.vcloud.orgVdcNetwork+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/238676ef-b5db-437d-af2b-2f9e6736aebf\" /> 
          <IpAddress>159.182.33.12</IpAddress> 
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
          <Pool>mystack-test</Pool> 
        </VirtualServer>
      </LoadBalancerService> 
    </EdgeGatewayServiceConfiguration> 
    <HaEnabled>true</HaEnabled> 
    <UseDefaultRouteForDnsRelay>false</UseDefaultRouteForDnsRelay> 
  </Configuration> 
</EdgeGateway>")

      #egw = @connection.get_edgegateway('95d60018-1752-41f3-ba77-11223344556677')
      #egw[:interfaces].count.must_equal 3
      #ap egw
    end

    it "should be able to substitute virtual server pool memeber IPs" do
      stub_request(:get, @url).
          to_return(:status => 200,
                    :headers => {:date=>"Fri, 10 Jan 2014 09:09:09 GMT", :content_type=>"application/vnd.vmware.admin.edgegateway+xml;version=5.1"},
                    :body => "
<EdgeGateway xmlns=\"http://www.vmware.com/vcloud/v1.5\" status=\"1\" name=\"test-edge-gateway\" id=\"urn:vcloud:gateway:95d60018-1752-41f3-ba77-11223344556677\" type=\"application/vnd.vmware.admin.edgeGateway+xml\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.vmware.com/vcloud/v1.5 http://testhost.local/api/v1.5/schema/master.xsd\">
  <Link rel=\"up\" type=\"application/vnd.vmware.vcloud.vdc+xml\" href=\"https://testhost.local/api/vdc/47dea0c7-f6c2-41b7-b270-a80216f924c3\" />
  <Link rel=\"edgeGateway:redeplo\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/redeploy\" />
  <Link rel=\"edgeGateway:configureServices\" type=\"application/vnd.vmware.admin.edgeGatewayServiceConfiguration+xml\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/configureServices\" />
  <Link rel=\"edgeGateway:reapplyServices\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/reapplyServices\" />
  <Link rel=\"edgeGateway:syncSyslogSettings\" href=\"https://testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/syncSyslogServerSettings\" />
  <Description>A Test Edge Gateway</Description>
  <Configuration>
    <GatewayBackingConfig>full</GatewayBackingConfig>
    <GatewayInterfaces />
    <EdgeGatewayServiceConfiguration>
      <FirewallService>
        <IsEnabled>false</IsEnabled>
      </FirewallService>
      <NatService />
      <LoadBalancerService>
        <IsEnabled>false</IsEnabled>
        <Pool>
          <Name>test_pool_01</Name>
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
          <ServicePort>
            <IsEnabled>false</IsEnabled>
            <Protocol>TCP</Protocol>
            <Algorithm>ROUND_ROBIN</Algorithm>
            <Port />
            <HealthCheckPort />
            <HealthCheck>
              <Mode>TCP</Mode>
              <HealthThreshold>2</HealthThreshold>
              <UnhealthThreshold>3</UnhealthThreshold>
              <Interval>5</Interval>
              <Timeout>15</Timeout>
            </HealthCheck>
          </ServicePort>
          <Member>
            <IpAddress>10.72.10.1</IpAddress>
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
            <IpAddress>10.72.10.2</IpAddress>
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
          <Name>mystack-dev-vip</Name>
          <Interface type=\"application/vnd.vmware.vcloud.orgVdcNetwork+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/1234567-b5db-437d-af2b-abcedrejg\" />
          <IpAddress>192.168.1.1</IpAddress>
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
          <Pool>test_pool_01</Pool>
        </VirtualServer>
      </LoadBalancerService>
    </EdgeGatewayServiceConfiguration>
    <HaEnabled>true</HaEnabled>
    <UseDefaultRouteForDnsRelay>false</UseDefaultRouteForDnsRelay>
  </Configuration>
</EdgeGateway>")

      new_members = ['10.10.100.1', '10.10.100.2']
      #new_members = ['10.163.18.7', '10.163.18.8']

      stub_request(:post, "https://testuser%40testorg:testpass@testhost.local/api/admin/edgeGateway/95d60018-1752-41f3-ba77-11223344556677/action/configureServices").
          with(:headers => {:content_type=>"application/vnd.vmware.admin.edgeGatewayServiceConfiguration+xml"},
               :body => "
<?xml version=\"1.0\"?>
<EdgeGatewayServiceConfiguration xmlns=\"http://www.vmware.com/vcloud/v1.5\">
  <FirewallService>
    <IsEnabled>false</IsEnabled>
  </FirewallService>
  <NatService />
  <LoadBalancerService>
    <IsEnabled>false</IsEnabled>
    <Pool>
      <Name>test_pool_01</Name>
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
      <ServicePort>
        <IsEnabled>false</IsEnabled>
        <Protocol>TCP</Protocol>
        <Algorithm>ROUND_ROBIN</Algorithm>
        <Port />
        <HealthCheckPort />
        <HealthCheck>
          <Mode>TCP</Mode>
          <HealthThreshold>2</HealthThreshold>
          <UnhealthThreshold>3</UnhealthThreshold>
          <Interval>5</Interval>
          <Timeout>15</Timeout>
        </HealthCheck>
      </ServicePort>
      <Member>
        <IpAddress>#{new_members[0]}</IpAddress>
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
        <IpAddress>#{new_members[0]}</IpAddress>
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
      <Name>mystack-dev-vip</Name>
      <Interface type=\"application/vnd.vmware.vcloud.orgVdcNetwork+xml\" name=\"External\" href=\"https://testhost.local/api/admin/network/1234567-b5db-437d-af2b-abcedrejg\" />
      <IpAddress>192.168.1.1</IpAddress>
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
      <Pool>test_pool_01</Pool>
    </VirtualServer>
  </LoadBalancerService>
</EdgeGatewayServiceConfiguration>").to_return(
          :status => 200,
          :body => "<Task xmlns=\"http://www.vmware.com/vcloud/v1.5\" status=\"running\" startTime=\"2014-01-13T10:58:23.939-06:00\" serviceNamespace=\"com.vmware.vcloud\" operationName=\"networkConfigureEdgeGatewayServices\" operation=\"Updating services EdgeGateway egw1(c705f7e7-1eb9-41ed-844a-e2e49be8d6a0)\" expiryTime=\"2014-04-13T10:58:23.939-05:00\" cancelRequested=\"false\" name=\"task\" id=\"urn:vcloud:task:4dcbc8e0-059f-4655-b567-dcc0e472ffd2\" type=\"application/vnd.vmware.vcloud.task+xml\" href=\"https://testuser%40testorg:testpass@testhost.local/api/task/4dcbc8e0-059f-4655-b567-dcc0e472ffd2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.vmware.com/vcloud/v1.5 http://10.163.4.41/api/v1.5/schema/master.xsd\"> 
	<Link rel=\"task:cancel\" href=\"https://testuser%40testorg:testpass@testhost.local/api/task/update-egw-test-task/action/cancel\" />
	<User type=\"application/vnd.vmware.admin.user+xml\" name=\"testuser\" href=\"https://testuser%40testorg:testpass@testhost.local/api/admin/user/cf00e729-719d-40fc-8e4c-d516cd74ea4d\" />
	<Organization type=\"application/vnd.vmware.vcloud.org+xml\" name=\"testorg\" href=\"https://testuser%40testorg:testpass@testhost.local/api/org/b3c44da0-7d8a-479f-9810-4e39d30fa1dc\" /> 
	<Progress>0</Progress> 
	<Details /> 
</Task>"
      )

    taskid = @connection.update_virtual_server_pool_members('95d60018-1752-41f3-ba77-11223344556677', 'test_pool_01', new_members)
    taskid.must_equal "update-egw-test-task"
    end
  end
end
