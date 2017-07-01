class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user
      can :show, Artefact, Artefact do |s|
        s.readable_by?(user)
      end
      can [:edit, :update, :destroy], Artefact, Artefact do |s|
        s.editable_by?(user)
      end
      can :show, Photo, Photo do |s|
        s.readable_by?(user)
      end
      can [:edit, :update, :destroy], Photo, Photo do |s|
        s.editable_by?(user)
      end

      can [:new, :create], [Photo, Artefact] if user.is_admin? || user.is_creator?

      can :import, [Artefact, Photo, ArtefactPhoto, ArtefactPerson, ArtefactReference] if user.is_admin? || user.is_creator?
    else
      can :show, Artefact, published?: true
      can :show, Photo, published?: true
    end
    can :index, [ArtefactPerson, ArtefactReference]
  end
end
