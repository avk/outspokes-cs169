# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include TagsHelper

def line_break(string)
    string.gsub("\n", '<br/>')
end


end
