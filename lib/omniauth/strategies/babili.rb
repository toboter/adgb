module OmniAuth
  module Strategies
    class Babili < ::OmniAuth::Strategies::OAuth2
      option :name, :babili

      option :client_options, {
        site: Rails.application.credentials.provider_site,
        authorize_path: '/oauth/authorize'
      }

      def callback_url
         full_host + script_name + callback_path
      end

      uid do
        raw_info["id"]
      end

      info do
        {
          email: raw_info["email"],
          birthday: raw_info["birthday"],
          gender: raw_info["gender"],
          name: raw_info["display_name"],
          image_thumb_50: raw_info["image_thumb_50"]
        }
      end

      def raw_info
        @raw_info ||= begin
          parsed = access_token.get('/v1/user.json').parsed
          # AMS :json adapter wraps as {"user": {...}}
          if parsed.is_a?(Hash) && parsed.key?("user")
            parsed["user"]
          else
            parsed
          end
        end
      end
    end
  end
end
