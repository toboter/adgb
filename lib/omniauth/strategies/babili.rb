module OmniAuth
  module Strategies
    class Babili < OmniAuth::Strategies::OAuth2
      option :name, :babili

      option :client_options, {
        site: Rails.application.secrets.provider_site,
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
          name: raw_info["display_name"]
          # and anything else you want to return to your API consumers
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/me.json').parsed
      end
    end
  end
end