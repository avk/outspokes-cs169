require File.dirname(__FILE__) + '/../test_helper'

class PageEditTest < ActiveSupport::TestCase

  def test_must_not_be_abstract
    pe = create_page_edit
    assert !pe.abstract?
  end

  def test_should_create_a_page_edit
    assert_difference "PageEdit.count", 1 do
      pe = create_page_edit
      assert !pe.new_record?, "#{pe.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_a_page
    assert_no_difference "PageEdit.count" do
      pe = create_page_edit(:page_id => nil)
      assert pe.errors.on(:page_id), "Allowing nil page_ids"
    end
  end
  
  def test_should_require_a_commenter
    assert_no_difference "PageEdit.count" do
      pe = create_page_edit(:commenter_id => nil)
      assert pe.errors.on(:commenter_id), "Allowing nil commenter_ids"
    end
  end
  
  def test_should_require_a_changeset
    assert_no_difference "PageEdit.count" do
      pe = create_page_edit(:changeset => nil)
      assert pe.errors.on(:changeset), "Allowing nil changesets"
    end
  end
  
  def test_should_require_valid_JSON_in_changeset
    pe = create_page_edit
    begin
      json = JSON.parse(pe.changeset)
      assert json.keys.size == 2
      assert json["copy"]
      assert json["styles"]
    rescue JSON::ParserError => e
      assert false, "invalid JSON in changeset: #{e}"
    end
  end

  # def test_should_not_store_any_top_level_json_attributes_except_copy_and_styles
  #   pe = create_page_edit
  #   valid_atts = {'copy' => {}, 'styles' => {}}
  #   invalid_atts = {'ranger' => {}, 'malicious' => {}}
  #   
  #   begin
  #     pe.changeset = valid_atts.merge(invalid_atts).to_json
  #     pe.save
  #     pe.reload
  #     json = JSON.parse(pe.changeset)
  #     assert json.keys.size == 2, "allowing invalid top-level attributes in changeset"
  #     assert json["copy"]
  #     assert json["styles"]
  #   rescue JSON::ParserError => e
  #     puts "rescued: #{e}"
  #   end
  # end

end
