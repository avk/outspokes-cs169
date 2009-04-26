class EmailReq < ActiveRecord::Base
  @@email_name_regex  = '[\w\.%\+\-]+'.freeze
  @@domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  @@domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  @@email_regex = /\A#{@@email_name_regex}@#{@@domain_head_regex}#{@@domain_tld_regex}\z/i
  
  validates_presence_of :email, :allow_blank => false
  validates_format_of :email, :with => @@email_regex  
  validates_uniqueness_of :email
end
