class Widget::UserStylesController < Widget::WidgetController


  def css_for_user_style
    @stored_json =   <<-eos
    {
                "html > div > div > span:eq(0)" : {
                    "background-color" : "#333",
                    "color" : "#efefef",
                    "font-family" : "Times New Roman, Arial, Helvetica, sans-serif"
                }
            }
            eos
            
    respond_to do |wants|
      wants.css
    end
  end
    

end
