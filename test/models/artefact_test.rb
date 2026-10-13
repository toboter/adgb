require 'test_helper'

class ArtefactTest < ActiveSupport::TestCase
  test "requires bab_rel" do
    artefact = Artefact.new
    assert_not artefact.valid?
    assert_includes artefact.errors[:bab_rel], "can't be blank"
  end

  test "fixture is valid" do
    assert artefacts(:one).valid?
  end
end
