class Api::WebhooksController < ActionController::API
  require 'json'

  before_action :set_token

  def sso_login

  end

  # application_url/api/hooks/update_accessibilities?access_token=babili-token
  def update_user_accessibilities
    if @token.blank?
      return render json: { message: 'missing access token', status: 401 }, status: :unauthorized
    end

    user_url = "#{Rails.application.credentials.provider_site}/v1/user"
    user_response = HttpClient.get(user_url, headers: { Authorization: "Bearer #{@token}" }, open_timeout: 10, timeout: 30)
    user_parsed = unwrap_babili_root(JSON.parse(user_response.body))
    user = User.where(provider: 'babili', uid: user_parsed['id']).first
    unless user
      return render json: { message: 'user not found for token', status: 404 }, status: :not_found
    end

    babili_access_url = "#{Rails.application.credentials.provider_site}/v1/authorizations/clients/#{Rails.application.credentials.client_id}"
    babili_access_resp = HttpClient.get(babili_access_url, headers: { Authorization: "Bearer #{@token}" }, open_timeout: 10, timeout: 30)
    babili_accessibilities = deep_ostruct(unwrap_babili_root(JSON.parse(babili_access_resp.body)))

    Array(babili_accessibilities.organization_accessors).each do |org|
      group = Group.where(gid: org.id, provider: 'babili').first_or_create! do |g|
        g.name = org.name
      end
      group.users = User.where(uid: org.member_ids, provider: 'babili')
    end

    perms = babili_accessibilities.user_permissions
    user.app_admin = perms.extra.manage
    user.app_creator = perms.create
    user.app_publisher = perms.extra.publish
    user.app_commentator = perms.extra.comment

    if user.save
      render json: { message: 'updated', status: 200 }, status: :ok
    else
      render json: { message: 'failed', status: 400 }, status: :bad_request
    end
  rescue Faraday::UnauthorizedError
    render json: { message: 'babili rejected access token', status: 401 }, status: :unauthorized
  rescue Faraday::ForbiddenError
    render json: { message: 'babili forbidden (token missing required scopes)', status: 403 }, status: :forbidden
  rescue Faraday::Error => e
    render json: { message: "babili request failed: #{e.message}", status: 502 }, status: :bad_gateway
  end

  private
  def set_token
    @token = request.headers['Authorization'] ? request.headers['Authorization'].split(' ').last : params[:access_token]
  end

  def unwrap_babili_root(data)
    if data.is_a?(Hash) && data.keys.size == 1 && !data.key?("meta")
      data.values.first
    else
      data
    end
  end

  def deep_ostruct(node)
    case node
    when Hash
      OpenStruct.new(node.transform_values { |value| deep_ostruct(value) })
    when Array
      node.map { |value| deep_ostruct(value) }
    else
      node
    end
  end

end