class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user
      can :show, Artefact, Artefact do |s|
        s.readable_by?(user)
      end
      can :unlock, Artefact if user.is_admin?
      can [:edit, :update, :publish, :destroy], Artefact, Artefact do |s|
        s.editable_by?(user) && !s.locked?
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
      can :unlock, Source if user.is_admin?
      can [:edit, :update, :publish, :destroy], Source, Source do |s|
        s.editable_by?(user) && !s.locked?
      end

      can [:new, :create], [PhotoImport, Artefact, Source] if user.is_admin? || user.is_creator?

      can :import, [Artefact, PhotoImport, ArtefactPhoto, ArtefactPerson, ArtefactReference] if user.is_admin? || user.is_creator?
    else
      can :show, Artefact, published?: true
      can :show, PhotoImport, published?: true
      can :show, Source, published?: true
    end
    can :index, [ArtefactPerson, ArtefactReference]
  end
end
