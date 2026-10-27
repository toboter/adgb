class SessionsController < ApplicationController
  after_action :update_user, only: :create

  def create
    auth = request.env["omniauth.auth"]
    token = auth["credentials"]["token"]

    user = User.where(provider: auth["provider"], uid: auth["uid"]).first_or_create! do |u|
      u.regenerate_token
      @new_user = true
    end

    session[:access_token] = auth["credentials"]["token"]
    session[:user_id] = user.id
    redirect_to (session[:user_return_to] || request.env['omniauth.origin'] || root_url), notice: "You have been signed in through #{user.provider.humanize}."
    session[:user_return_to] = nil
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil
    session[:per_page] = nil

    redirect_to root_url, notice: "Bye!"
  end
  
  def set_per_page
    session[:per_page] = params[:per_page].to_i
    redirect_back(fallback_location: root_path)
  end

  private
  def update_user
    user = User.find(session[:user_id])
    babili_user = parse_babili_json(access_token.get('/v1/user').body)
    babili_accessibilities = parse_babili_json(
      access_token.get("/v1/authorizations/clients/#{Rails.application.credentials.client_id}").body
    )

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

    user.email = babili_user.email
    user.name = babili_user.display_name
    user.image_thumb_url = babili_user.image_thumb_50

    flash[:success] = 'User info and permissions updated' if user.save
    set_local_token_on_babili if @new_user.present?
  end

  def set_local_token_on_babili
    # Register this app's API token on each Babili collection for this host.
    # /v1/user/repositories is still the list endpoint; token CRUD uses /v1/collections.
    collections = Array(
      parse_babili_json(
        access_token.get("/v1/collections/resources/#{Rails.application.credentials.host_id}").body
      )
    )

    if collections.any? && current_user.regenerate_token
      begin
        collections.each do |c|
          data = {token: current_user.token, token_type: 'Token'}
          resp = access_token.post("/v1/collections/#{c.id}/tokens", body: data)
          flash[:notice] = (resp.status == 201 ? "Token received." : 'An error occured.')
        end
      rescue OAuth2::Error => e
        flash[:alert] = "The Server ist returning #{e}. Token not sent."
      end
    else
      flash[:alert] = "Token not created. #{'No collections found.' if collections.empty?}"
    end
  end
end