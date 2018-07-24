class GrantsController < ApplicationController
  before_action :set_resource, except: [:grant_multiple, :revoke_multiple]
  before_action :set_grant, only: [:update, :destroy]

  def candidates
    users = User.all
    groups = Group.all
    users = users.search(params[:search]) if params[:search]
    groups = groups.search(params[:search]) if params[:search]
    @candidates = (users + groups).map{|o|[o.name, [o.class.name, o.id]]} - @resource.shared_with.map{|w| [w.shared_to.name, [w.shared_to_type, w.shared_to_id]]}

    render json: @candidates.map{|c| [ 'name' => c[0], 'id' => c[1] ]}
  end

  # grant
  def create
    authorize! :grant_access, @resource
    share_to = params[:share_to].split(',')
    share_to_klass = share_to.first.classify.constantize
    @share_to = share_to_klass.find(share_to.last)

    respond_to do |format|
      if params[:commit] == 'Allow write' ? @resource.allow_edit(current_user, @share_to) : @resource.share_it(current_user, @share_to)
        @grant = @resource.shares.where(shared_to: @share_to, shared_from: current_user).first
        format.html { redirect_to @resource, notice: 'Access successfully granted.' }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def update
    authorize! :update_access, @resource
    respond_to do |format|
      if @grant.update(grant_params)
        format.html { redirect_to @resource, notice: 'Share was successfully updated.' }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  # revoke
  def destroy
    authorize! :revoke_access, @resource
    @resource.throw_out(current_user, @grant.shared_to)
    respond_to do |format|
      format.html { redirect_to @resource, notice: 'Share was successfully destroyed.' }
      format.js
    end
  end


  def grant_multiple
    accessors = params[:accessors] ? params[:accessors].map{ |a| a.split(' ').map{|b| b.strip } }.map{ |h| h.last.classify.constantize.find(h.first) }.compact : false
    editors = params[:can_edit] ? params[:can_edit].map{ |a| a.split(' ').map{|b| b.strip } }.map{ |h| h.last.classify.constantize.find(h.first) }.compact : false
    model_class = params[:model_name].constantize

    authorize! :grant_multiple_access, model_class

    records = model_class.visible_for(current_user).all
    query = params[:search].presence || '*'
    if model_class.respond_to?(:filter)
     records = records.filter(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))
    end

    sk_results = model_class.search(query, 
      where: { id: records.ids },
      fields: [:default_fields],
      per_page: 10000,
      misspellings: {below: 1}
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end

    results = model_class.where(id: sk_results.map(&:id))

    results.in_batches.each do |records|
      @values = []
      accessors.each do |accessor|
        can_edit = editors ? (editors.include?(accessor) ? true : false) : false
        @values << records.map {|record| "(#{accessor.id},'#{accessor.class.name}',#{record.id},'#{record.class.base_class.name}',#{current_user.id},'#{current_user.class.name}',#{can_edit},now(),now())" }
      end
      ActiveRecord::Base.connection.execute("INSERT INTO share_models (shared_to_id, shared_to_type, resource_id, resource_type, \
        shared_from_id, shared_from_type, edit, created_at, updated_at) VALUES #{@values.flatten.compact.to_a.join(",")} ON CONFLICT (resource_id, resource_type, shared_to_id, shared_to_type) DO NOTHING") # ON CONFLICT DO UPDATE
    end
    redirect_to [model_class, search: params[:search]], notice: "Successfully granted access to #{view_context.pluralize(results.count, model_class.name)}."
  end


  def revoke_multiple
    @accessors = params[:accessors]
    model_class = params[:model_name].constantize

    authorize! :revoke_multiple_access, model_class    

    records = model_class.visible_for(current_user).all
    query = params[:search].presence || '*'
    if model_class.respond_to?(:filter)
      records = records.filter(params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records))
    end

    sk_results = model_class.search(query, 
      where: { id: records.ids },
      fields: [:default_fields],
      per_page: 10000 ,
      misspellings: {below: 1}
      ) do |body|
        body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
      end

    results = model_class.where(id: sk_results.map(&:id))

    @acc_instances =[]
    @accessors.each do |accessor|
      acc_hash = accessor.split(' ').map{|a| a.strip }
      @acc_instances << acc_hash.last.classify.constantize.find(acc_hash.first)
    end

    results.in_batches.each do |records|
      ShareModel.where(shared_to: @acc_instances, resource_id: records.ids, resource_type: model_class.name).delete_all
    end
    

    redirect_to [model_class, search: params[:search]], notice: "Successfully revoked access to #{view_context.pluralize(results.count, model_class.name)}."
  end


  private
    def set_resource
      parent_class = params[:model_name].constantize
      parent_foreing_key = params[:model_name].foreign_key
    
      @resource = parent_class.friendly.find(params[parent_foreing_key])
    end
    
    def set_grant
      @grant = @resource.shares.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grant_params
      params.require(:grant).permit(:resource_type, :resource_id, :shared_to, :edit, :share_to_children)
    end

end
