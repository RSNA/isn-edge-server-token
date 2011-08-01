=begin rdoc
=Description
This is an active record model generated by the restful-authentication plugin and slightly modified.
=end
class User < ActiveRecord::Base
  require 'digest/sha1'
  set_primary_key :user_id
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :user_login
  validates_length_of       :user_login,    :within => 3..40
  validates_uniqueness_of   :user_login
  validates_format_of       :user_login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :user_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :user_name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :user_login, :email, :user_name, :password, :password_confirmation, :role

  def validate
    if self.password != nil and self.password.blank?
      errors.add(:password, "cannot be left blank")
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_user_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Alias for +find(id)+
  def self.find_by_id(id)
    self.find(id)
  end

  # Alias for user_login
  def login
    self.user_login
  end

  # Setter alias for user_login=
  def login=(value)
    write_attribute :user_login, (value ? value.downcase : nil)
  end

  # Setter methdo for email attribute
  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # Returns true if the user is an administartor
  def admin?
    self.role_id == 2
  end

  # Returns true if the user is a super user or administartor
  def super?
    self.role_id >= 1
  end

end
