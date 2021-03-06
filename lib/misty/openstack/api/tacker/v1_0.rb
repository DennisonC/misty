require 'misty/openstack/api/tacker/tacker_v1_0'
require 'misty/openstack/service_pack'

module Misty
  module Openstack
    module API
      module Tacker
        class V1_0
          include Misty::Openstack::API::TackerV1_0
          include Misty::Openstack::ServicePack

          def service_types
            %w(nfv-orchestration)
          end
        end
      end
    end
  end
end
