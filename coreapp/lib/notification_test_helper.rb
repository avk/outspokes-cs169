# include this module into the unit tests of models that subclass
# Feedback. e.g. Comment, UserStyle

module NotificationTestHelper
  def self.included(base)
    begin
      model_class = base.name.gsub("Test", "").constantize
    rescue NameError
      raise "Include this test helper for classes that add to notifications"
    end

    test_method = "create_#{model_class.to_s.underscore}"

    base.class_eval <<-EOT
    test "should put a notification after save" do
      assert_difference 'Notification.count' do
        #{test_method}
      end
    end
    EOT
  end
end
