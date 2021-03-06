module MarketplaceService
  module Community
    CommunityModel = ::Community

    module Entity
      # module_function
    end

    module Command

      # module_function

    end

    module Query
      module_function

      def payment_type(community_id)
        Maybe(CommunityModel.find_by_id(community_id))
          .map { |community|
            if community.paypal_enabled
              :paypal
            else
              community.payment_gateway.gateway_type
            end
          }
          .or_else(nil)
      end

    end
  end
end
