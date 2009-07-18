require File.dirname(__FILE__) + '/../test_helper'

class UserStyleTest < ActiveSupport::TestCase

  def test_must_not_be_abstract
    user_style = create_user_style
    assert !user_style.abstract?
  end

  def test_should_create_a_user_style
    assert_difference "UserStyle.count", 1 do
      user_style = create_user_style
      assert !user_style.new_record?, "#{user_style.errors.full_messages.to_sentence}"
    end
  end

  test "should put a notification after save" do
    assert_difference 'Notification.count' do
      create_user_style
    end
  end
  
  def test_should_require_a_page
    assert_no_difference "UserStyle.count" do
      user_style = create_user_style(:page => nil)
      assert user_style.errors.on(:page), "Allowing nil page"
    end
  end
  
  def test_should_require_a_commenter
    assert_no_difference "UserStyle.count" do
      user_style = create_user_style(:commenter => nil)
      assert user_style.errors.on(:commenter), "Allowing nil commenter"
    end
  end
  
  def test_should_require_a_changeset
    assert_no_difference "UserStyle.count" do
      user_style = create_user_style(:changeset => nil)
      assert user_style.errors.on(:changeset), "Allowing nil changesets"
    end
  end
  
  def test_should_require_valid_JSON_in_changeset
    user_style = create_user_style
    begin
      json = JSON.parse(user_style.changeset)
      # assert json.keys.size == 2
      # assert json["copy"]
      # assert json["styles"]
    rescue JSON::ParserError => e
      assert false, "invalid JSON in changeset: #{e}"
    end
  end

  # def test_should_not_store_any_top_level_json_attributes_except_copy_and_styles
  #   user_style = create_user_style
  #   valid_atts = {'copy' => {}, 'styles' => {}}
  #   invalid_atts = {'ranger' => {}, 'malicious' => {}}
  #   
  #   begin
  #     user_style.changeset = valid_atts.merge(invalid_atts).to_json
  #     user_style.save
  #     user_style.reload
  #     json = JSON.parse(user_style.changeset)
  #     assert json.keys.size == 2, "allowing invalid top-level attributes in changeset"
  #     assert json["copy"]
  #     assert json["styles"]
  #   rescue JSON::ParserError => e
  #     puts "rescued: #{e}"
  #   end
  # end

end
