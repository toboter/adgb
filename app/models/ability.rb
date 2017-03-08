class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can :read, Artefact do |artefact|
      artefact.accessors.include?(user) || artefact.accessors.empty?
    end

    can :manage, Artefact do |artefact|
      artefact.accessors.empty? ? user.can_manage? : (artefact.accessors.include?(user) && user.can_manage?)
    end
    cannot :create, Artefact unless user.can_manage?

    can :read, [ArtefactPhoto, ArtefactPerson, ArtefactReference, Photo]

    can :manage, Photo do |photo|
      user.can_manage?
    end

    can :manage, Accessibility if user.can_manage?

  end
end
