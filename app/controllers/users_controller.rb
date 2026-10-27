class UsersController < ApplicationController
  before_action :authorize
  before_action :administrative, only: [:index, :update, :destroy]
  before_action :set_user, only: [:update, :destroy]

  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def settings
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
        format.js
      else
        format.html { redirect_to users_path, alert: 'Something went wrong.' }
        format.js
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_token_to_babili
    repos = Array(
      parse_babili_json(
        access_token.get("/v1/collections/resources/#{Rails.application.credentials.host_id}").body
      )
    )

    if repos.any? && current_user.regenerate_token
      begin
        repos.each do |r|
          data = {token: current_user.token, token_type: 'Token'}
          resp = access_token.post("/v1/collections/#{r.id}/tokens", body: data)
          flash[:notice] = (resp.status == 201 ? "Token received." : 'An error occured.')
        end
        redirect_to settings_users_url, notice: 'Updated'
      rescue OAuth2::Error => e
        redirect_to settings_users_url, alert: "The Server ist returning #{e}. Token not sent."
      end
    else
      redirect_to settings_users_url, alert: "Token not created. #{'No collections found.' if repos.empty?}"
    end
  end

  def update_accessibilities
    unless current_user && access_token
      redirect_to settings_users_url, alert: 'Not signed in to Babili.'
      return
    end

    babili_accessibilities = parse_babili_json(
      access_token.get("/v1/authorizations/clients/#{Rails.application.credentials.client_id}").body
    )
    user = current_user

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

    respond_to do |format|
      if user.save
        format.html { redirect_to settings_users_url, notice: 'Your accessibilities have been successfully updated.' }
      else
        format.html { redirect_to settings_users_url, notice: 'An error occured.' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:token, :id, :username, :app_admin, :app_commentator, :app_creator, :app_publisher, :group_list => [])
    end

end