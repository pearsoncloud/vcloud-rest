vcloud-rest [![Build Status](https://secure.travis-ci.org/astratto/vcloud-rest.png?branch=master)](http://travis-ci.org/astratto/vcloud-rest) [![Dependency Status](https://gemnasium.com/astratto/vcloud-rest.png)](https://gemnasium.com/astratto/vcloud-rest)
===========

DESCRIPTION
--
Unofficial ruby bindings for VMware® vCloud Director's rest APIs.

Note: at this stage both _v.1.5_ and _v.5.1_ are supported. It defaults to _v.5.1_ but it's possible to specify *_api_version="1.5"*.

See [vCloud API](http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.doc_51/GUID-86CA32C2-3753-49B2-A471-1CE460109ADB.html) for details.

INSTALLATION
--
This plugin is distributed as a Ruby Gem but since we have forked the source and made some additions please use bundler to install this Gem by
adding a line like this to your Gemfile:

    gem "vcloud-rest",      :git => 'git@github.com:pearsoncloud/vcloud-rest.git', :tag => 'v1.2.0' 

Alternativley you man install the original Gem from RubyGems like this:

    gem install vcloud-rest

Depending on your system's configuration, you may need to run this command with root privileges.

vcloud-rest is tested against ruby 2.0.0, 1.9.x and 1.8.7+.

FEATURES
--
- login/logout
- list/show Organizations
- show VDCs
- show Catalogs
- show Catalog Items
- various vApp's commands
    - show
    - create/clone
    - start/stop/delete/reset/suspend/reboot
    - basic network configuration
- basic VM configuration
    - show
    - set cpu/RAM
    - add VM metadata
    - basic network configuration
    - basic VM Guest Customization configuration
    - start/stop/delete/reset/suspend/reboot
- basic vApp compose capabilities
- basic vApp NAT port forwarding creation
- Catalog item upload with byterange upload and retry capabilities
- show Network details
- Some initial Edge Gateway configuration functionality:
    - Update the members of pre-existing Load Balancer Pool

TODO
--
- extend test coverage
- a lot more...

PREREQUISITES
--
- nokogiri ~> 1.6.0
- rest-client ~> 1.6.7
- httpclient ~> 2.3.3
- ruby-progressbar ~> 1.1.1

For testing purpose:
- minitest (included in ruby 1.9)
- webmock

USAGE
--

    require 'vcloud-rest/connection'
    conn = VCloudClient::Connection.new(HOST, USER, PASSWORD, ORG_NAME)
    conn.login
    conn.list_organizations

EXAMPLE
--
A (mostly complete) example can be found in

    examples/example.rb

DEBUGGING
--
Debug can be enabled setting the following environment variables:

* *VCLOUD_REST_DEBUG_LEVEL*: to specify the log level (e.g., INFO)
* *VCLOUD_REST_LOG_FILE*: to specify the output file (defaults to STDOUT)

TESTING
--
Simply run:

    rake
Or:

    ruby spec/connection_spec.rb

Note: in order to run tests with ruby 1.8.7+ you need to export RUBYOPT="rubygems"

RELEASING
--
Since we are 'privately' managing this Gem (i.e: we can't put it on RubyGems) the release
process, now using Jeweler, is as follows:

    rake version:bump:minor  # or rake version:bump:patch
    rake gemspec
    git commit -a -m "Release <NEW_VERSION>" 
    rake release


LICENSE
--

Author:: Stefano Tortarolo <stefano.tortarolo@gmail.com>

Copyright:: Copyright (c) 2012-2013
License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

CREDITS
--
This code was inspired by [knife-cloudstack](https://github.com/CloudStack-extras/knife-cloudstack).
