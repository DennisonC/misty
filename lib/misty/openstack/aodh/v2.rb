require 'misty/openstack/aodh/aodh_v2'
require 'misty/client_pack'

module Misty
  module Openstack
    module Aodh
      class V2
        extend Misty::Openstack::AodhV2
        include Misty::ClientPack

        def api
          self.class.v2
        end

        def service_names
          %w{alarming}
        end
      end
    end
  end
end
