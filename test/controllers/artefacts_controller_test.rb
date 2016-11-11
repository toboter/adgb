require 'test_helper'

class ArtefactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @artefact = artefacts(:one)
  end

  test "should get index" do
    get artefacts_url
    assert_response :success
  end

  test "should get new" do
    get new_artefact_url
    assert_response :success
  end

  test "should create artefact" do
    assert_difference('Artefact.count') do
      post artefacts_url, params: { artefact: { UTMx: @artefact.UTMx, UTMxx: @artefact.UTMxx, UTMy: @artefact.UTMy, UTMyy: @artefact.UTMyy, abguss: @artefact.abguss, abklatsch: @artefact.abklatsch, arkiv: @artefact.arkiv, b_join: @artefact.b_join, b_korr: @artefact.b_korr, bab: @artefact.bab, bab_ind: @artefact.bab_ind, bab_rel: @artefact.bab_rel, datum: @artefact.datum, diss: @artefact.diss, f_obj: @artefact.f_obj, fo1: @artefact.fo1, fo2: @artefact.fo2, fo3: @artefact.fo3, fo4: @artefact.fo4, fo_tell: @artefact.fo_tell, fo_text: @artefact.fo_text, grab: @artefact.grab, grabung: @artefact.grabung, inhalt: @artefact.inhalt, jahr: @artefact.jahr, kod: @artefact.kod, m_join: @artefact.m_join, m_korr: @artefact.m_korr, mas1: @artefact.mas1, mas2: @artefact.mas2, mas3: @artefact.mas3, mus_id: @artefact.mus_id, mus_ind: @artefact.mus_ind, mus_nr: @artefact.mus_nr, mus_sig: @artefact.mus_sig, period: @artefact.period, sig: @artefact.sig, standort: @artefact.standort, standort_alt: @artefact.standort_alt, text: @artefact.text, text_in_archiv: @artefact.text_in_archiv, zeil1: @artefact.zeil1, zeil2: @artefact.zeil2 } }
    end

    assert_redirected_to artefact_url(Artefact.last)
  end

  test "should show artefact" do
    get artefact_url(@artefact)
    assert_response :success
  end

  test "should get edit" do
    get edit_artefact_url(@artefact)
    assert_response :success
  end

  test "should update artefact" do
    patch artefact_url(@artefact), params: { artefact: { UTMx: @artefact.UTMx, UTMxx: @artefact.UTMxx, UTMy: @artefact.UTMy, UTMyy: @artefact.UTMyy, abguss: @artefact.abguss, abklatsch: @artefact.abklatsch, arkiv: @artefact.arkiv, b_join: @artefact.b_join, b_korr: @artefact.b_korr, bab: @artefact.bab, bab_ind: @artefact.bab_ind, bab_rel: @artefact.bab_rel, datum: @artefact.datum, diss: @artefact.diss, f_obj: @artefact.f_obj, fo1: @artefact.fo1, fo2: @artefact.fo2, fo3: @artefact.fo3, fo4: @artefact.fo4, fo_tell: @artefact.fo_tell, fo_text: @artefact.fo_text, grab: @artefact.grab, grabung: @artefact.grabung, inhalt: @artefact.inhalt, jahr: @artefact.jahr, kod: @artefact.kod, m_join: @artefact.m_join, m_korr: @artefact.m_korr, mas1: @artefact.mas1, mas2: @artefact.mas2, mas3: @artefact.mas3, mus_id: @artefact.mus_id, mus_ind: @artefact.mus_ind, mus_nr: @artefact.mus_nr, mus_sig: @artefact.mus_sig, period: @artefact.period, sig: @artefact.sig, standort: @artefact.standort, standort_alt: @artefact.standort_alt, text: @artefact.text, text_in_archiv: @artefact.text_in_archiv, zeil1: @artefact.zeil1, zeil2: @artefact.zeil2 } }
    assert_redirected_to artefact_url(@artefact)
  end

  test "should destroy artefact" do
    assert_difference('Artefact.count', -1) do
      delete artefact_url(@artefact)
    end

    assert_redirected_to artefacts_url
  end
end
