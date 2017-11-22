require 'misty/openstack/designate/designate_v2'
require 'misty/client_pack'

module Misty
  module Openstack
    module Designate
      class V2
        extend Misty::Openstack::DesignateV2
        include Misty::ClientPack

        def api
          self.class.v2
        end

        def service_names
          %w{dns}
        end
      end
    end
  end
end
