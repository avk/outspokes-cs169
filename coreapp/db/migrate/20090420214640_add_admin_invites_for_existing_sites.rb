class AddAdminInvitesForExistingSites < ActiveRecord::Migration
  def self.up
    Site.all.each do |site|
      begin
        i = Invite.new(:page => site.home_page, :commenter => site.account)
        i.save!
      rescue ActiveRecord::RecordInvalid => e
        puts "Couldn't invite #{site.account.email} (admin) to home page: #{site.home_page.url}"
        puts e
      end
    end
  end

  def self.down
    puts "destroying all admin invites (i.e. url_tokens)..."
    sleep(5)
    Site.all.each do |site|
      if i = Invite.find_by_page_id_and_commenter_id(site.home_page.id, site.account.id)
        i.destroy
      end
    end
  end
end
