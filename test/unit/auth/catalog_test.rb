require 'test_helper'

describe Misty::Auth::Catalog::V3 do
  let(:payload) do
    [{"endpoints"=>
      [{"region_id"=>"regionOne",
        "url"=>"http://localhost:9696",
        "region"=>"regionOne",
        "interface"=>"internal",
        "id"=>"id_endpoint1_internal"},
       {"region_id"=>"regionOne",
        "url"=>"http://localhost:9696",
        "region"=>"regionOne",
        "interface"=>"public",
        "id"=>"id_endpoint1_public"},
       {"region_id"=>"regionOne",
        "url"=>"http://localhost:9696",
        "region"=>"regionOne",
        "interface"=>"admin",
        "id"=>"id_endpoint1_admin"}],
     "type"=>"network",
     "id"=>"id1",
     "name"=>"neutron"},
    {"endpoints"=>
      [{"region_id"=>"regionOne",
        "url"=>"http://localhost:9292",
        "region"=>"regionOne",
        "interface"=>"internal",
        "id"=>"id_endpoint1_internal"},
       {"region_id"=>"regionOne",
        "url"=>"http://localhost:9292",
        "region"=>"regionOne",
        "interface"=>"public",
        "id"=>"id_endpoint1_public"},
       {"region_id"=>"regionOne",
        "url"=>"http://localhost:9292",
        "region"=>"regionOne",
        "interface"=>"admin",
        "id"=>"id_endpoint1_admin"}],
     "type"=>"image",
     "id"=>"id2",
     "name"=>"glance"},
    {"endpoints"=>
      [{"region_id"=>"regionOne",
        "url"=>"http://localhost:5000",
        "region"=>"regionOne",
        "interface"=>"internal",
        "id"=>"id_endpoint1_internal"},
       {"region_id"=>"regionOne",
        "url"=>"http://localhost:5000",
        "region"=>"regionOne",
        "interface"=>"public",
        "id"=>"id_endpoint1_public"},
       {"region_id"=>"regionOne",
        "url"=>"http://localhost:35357",
        "region"=>"regionOne",
        "interface"=>"admin",
        "id"=>"id_endpoint1_admin"}],
     "type"=>"identity",
     "id"=>"id3",
     "name"=>"keystone"},
    {"endpoints"=>
      [{"region_id"=>"regionOne",
        "url"=>"http://localhost2:5000",
        "region"=>"regionTwo",
        "interface"=>"internal",
        "id"=>"id_endpoint1_internal"},
       {"region_id"=>"regionTwo",
        "url"=>"http://localhost2:5000",
        "region"=>"regionTwo",
        "interface"=>"public",
        "id"=>"id_endpoint1_public"},
       {"region_id"=>"regionTwo",
        "url"=>"http://localhost2:35357",
        "region"=>"regionTwo",
        "interface"=>"admin",
        "id"=>"id_endpoint1_admin"}],
     "type"=>"identity",
     "id"=>"id3",
     "name"=>"keystone"}]
  end

  describe '#get_endpoint_url' do
    it 'with matching name, interface and region' do
      catalog = Misty::Auth::Catalog::V3.new(payload)
      catalog.get_endpoint_url('identity', 'admin', 'regionTwo').must_equal 'http://localhost2:35357'
    end

    it 'with matching name and interface using avail region' do
      catalog = Misty::Auth::Catalog::V3.new(payload)
      catalog.get_endpoint_url('network', ['dummy', 'admin']).must_equal 'http://localhost:9696'
    end

    it 'with matching name and interface list' do
      catalog = Misty::Auth::Catalog::V3.new(payload)
      catalog.get_endpoint_url('network', ['dummy', 'admin']).must_equal 'http://localhost:9696'
    end

    it 'with matching name and interface and several regions available' do
      catalog = Misty::Auth::Catalog::V3.new(payload)
      proc do
        catalog.get_endpoint_url('identity', 'admin')
      end.must_raise Misty::Auth::Catalog::EndpointError
    end

    it 'with unmatched name for service type' do
      catalog = Misty::Auth::Catalog::V3.new(payload)
      proc do
        catalog.get_endpoint_url('service', 'public')
        end.must_raise Misty::Auth::Catalog::ServiceTypeError
    end

    it 'with unmatched region' do
      catalog = Misty::Auth::Catalog::V3.new(payload)
      proc do
        catalog.get_endpoint_url('identity', 'admin', 'regionOther')
      end.must_raise Misty::Auth::Catalog::EndpointError
    end

    it 'with unmatched interface' do
      catalog = Misty::Auth::Catalog::V3.new(payload)
      proc do
        catalog.get_endpoint_url('identity', 'private')
      end.must_raise Misty::Auth::Catalog::EndpointError
    end
  end
end

describe Misty::Auth::Catalog::V2 do
  let(:payload) do
    [{ 'endpoints' =>
      [{ 'adminURL' => 'http://localhost',
        'region' => 'regionOne',
        'internalURL' => 'http://localhost:8888/v2.0',
        'id' => 'id_endpoints',
        'publicURL' => 'http://localhost' }],
        'endpoints_links' => [],
        'type' => 'identity',
        'name' => 'keystone' },
     { 'endpoints' =>
      [{ 'adminURL' => 'http://localhost',
        'region' => 'regionTwo',
        'internalURL' => 'http://localhost:9999/v2.0',
        'id' => 'id_endpoints',
        'publicURL' => 'http://localhost' }],
        'endpoints_links' => [],
        'type' => 'identity',
        'name' => 'keystone' },
    { 'endpoints' =>
     [{ 'adminURL' => 'http://localhost',
        'region' => 'regionOne',
        'internalURL' => 'http://localhost:7777/v1.0',
        'id' => 'id_endpoints',
        'publicURL' => 'http://localhost' }],
        'endpoints_links' => [],
        'type' => 'compute',
        'name' => 'nova' }
      ]
  end

  describe '#get_endpoint_url' do
    it 'match name, interface and region' do
      catalog = Misty::Auth::Catalog::V2.new(payload)
      catalog.get_endpoint_url('identity', 'internal', 'regionTwo').must_equal 'http://localhost:9999/v2.0'
    end

    it 'match name, interface and unique region available' do
      catalog = Misty::Auth::Catalog::V2.new(payload)
      catalog.get_endpoint_url('compute', 'internal').must_equal 'http://localhost:7777/v1.0'
    end

    it 'fails when multiple region match' do
      catalog = Misty::Auth::Catalog::V2.new(payload)
      proc do
        catalog.get_endpoint_url('identity', 'admin')
      end.must_raise Misty::Auth::Catalog::EndpointError
    end

    it 'with unmatched arguments' do
      catalog = Misty::Auth::Catalog::V2.new(payload)
      proc do
        catalog.get_endpoint_url('test', 'unknown', 'regionOther')
      end.must_raise Misty::Auth::Catalog::ServiceTypeError
    end

    it 'with unmatched region' do
      catalog = Misty::Auth::Catalog::V2.new(payload)
      proc do
        catalog.get_endpoint_url('identity', 'admin', 'regionOther')
      end.must_raise Misty::Auth::Catalog::EndpointError
    end

    it 'with unmatched interface' do
      catalog = Misty::Auth::Catalog::V2.new(payload)
      proc do
        catalog.get_endpoint_url('identity', 'private','regionTwo')
      end.must_raise Misty::Auth::Catalog::EndpointError
    end
  end
end
