class Ability
  include CanCan::Ability

  def initialize(user)
    can :index, Artefact, published?: true
    can :index, Source, published?: true
    cannot :read, 'museum_internals'

    # user ||= User.new # guest user (not logged in)
    if user
      can :read, [ArtefactPerson, ArtefactReference, Archive, LiteratureItem]
      can [:new, :create], Archive
      can [:edit, :update], LiteratureItem
      can :show, Artefact, Artefact do |s|
        s.readable_by?(user)
      end
      can [:edit, :update, :destroy, :grant_access, :update_access, :revoke_access], Artefact, Artefact do |a|
        a.editable_by?(user) && !a.locked?
      end
      can :show, PhotoImport, PhotoImport do |s|
        s.readable_by?(user)
      end
      can [:edit, :update, :destroy], PhotoImport, PhotoImport do |s|
        s.editable_by?(user)
      end
      can :show, Source, Source do |s|
        s.readable_by?(user)
      end
      can [:edit, :update, :destroy, :grant_access, :update_access, :revoke_access], Source, Source do |s|
        s.editable_by?(user) && !s.locked?
      end

      can :manage, [Artefact, Source, Archive, PhotoImport, ArtefactPhoto, ArtefactPerson, ArtefactReference, LiteratureItem] if user.is_admin?
      can :update_concept_data, :tags if user.is_admin?#


      cannot :read, 'museum_internals'
      can :read, 'museum_internals' if user.is_admin? || user.is_publisher? || user.is_creator?
    end
  end
end
