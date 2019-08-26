class TagsController < ApplicationController
  def update_concept_data
    authorize! :update_concept_data, :tags
    tags=[]
    ActsAsTaggableOn::Tag.all.each do |t|
      if t.uuid.present?
        concept = Wrapper::Vocab.find(t.uuid, access_token)
        default_name = concept['prefLabel'].try('[]', 'de') || concept['prefLabel'].try('[]', 'en') || 'unknown language'
        default_url = concept['links']['html']
        tags << t.update(concept_data: concept, name: default_name, url: default_url)
        t.taggings.each do |o|
          o.taggable.reindex
        end
      end
    end if current_user.is_admin?
    redirect_to settings_users_path, notice: "#{view_context.pluralize(tags.size, 'concept')} successfuly updated from babylon-online.org/"
  end
end