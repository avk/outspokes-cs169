# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8bebb5a04cdeb49f59ca9bc51a08d827'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  # expects params[:emails] and @site
  def invite_commenters
    emails = Commenter.parse_email_addresses(params[:emails])
    
    emails[:legal].each do |email|
      begin
        Commenter.transaction do
          if c = Commenter.find_by_email(email)
            # fails transaction if already invited to this page
            raise "double invite!" if c.pages.include? @site.home_page
          else
            c = Commenter.new(:email => email)
            c.save!
          end
          i = Invite.new(:page => @site.home_page, :commenter => c)
          i.save!

          Mailer.deliver_commenter_invite(i)
        end
      rescue
        flash[:warning] = "Could not invite one or more of: #{emails[:legal].join(', ')}"
      end
    end
    
    unless emails[:illegal].empty?
      flash[:error] = "Could not invite #{emails[:illegal].join(', ')}"
      return false
    end
    return true
  end
  
  
  def validate_callback
    # According to http://www.functionx.com/javascript/Lesson05.htm, JS functions:
    # - Must start with a letter or an underscore
    # - Can contain letters, digits, and underscores in any combination
    # - Cannot contain spaces
    # - Cannot contain special characters

    # Also:
    # - Cannot be a JavaScript keyword

    # On one line to please rcov, doesn't pick the whole array up as having full coverage otherwise
    js_keywords = %w(break continue do for import new this void case default else function in return typeof while comment delete export if label switch var with abstract implements protected boolean instanceOf public byte int short char interface static double long synchronized false native throws final null transient float package true goto private catch enum throw class extends try const finally debugger super alert eval Link outerHeight scrollTo Anchor FileUpload location outerWidth Select Area find Location Packages self arguments focus locationbar pageXoffset setInterval Array Form Math pageYoffset setTimeout assign Frame menubar parent status blur frames MimeType parseFloat statusbar Boolean Function moveBy parseInt stop Button getClass moveTo Password String callee Hidden name personalbar Submit caller history NaN Plugin sun captureEvents History navigate print taint Checkbox home navigator prompt Text clearInterval Image Navigator prototype Textarea clearTimeout Infinity netscape Radio toolbar close innerHeight Number ref top closed innerWidth Object RegExp toString confirm isFinite onBlur releaseEvents unescape constructor isNan  onError Reset untaint Date java onFocus resizeBy unwatch defaultStatus JavaArray onLoad resizeTo valueOf document JavaClass onUnload routeEvent watch Document JavaObject open scroll window Element JavaPackage opener scrollbars Window escape length Option scrollBy)

    @callback = params[:callback]

    return if @callback.nil? # no callback should be OK -- return plain JSON or HTML window.name

    @callback.strip!

    okay = true
    js_keywords.each do |word|
      if @callback == word
        okay = false
        break
      end
    end
    okay = false unless @callback.match(/\A[a-zA-Z_]+[\w\.]*\Z/)

    render :text => '{}' unless okay
  end
  
  def same_domain?(url1, url2)
    URI.parse(url1).host() == URI.parse(url2).host() && URI.parse(url1).port() == URI.parse(url2).port()
  end

  def sanitize(value, newlines)
    value = ERB::Util.html_escape(value)
    if newlines
      replace_val = "<br />"
    else
      replace_val = " "
    end
    value.gsub!(/\r\n/, replace_val)
    value.gsub!(/[\r\n]/, replace_val)
    return value
  end
  
end
