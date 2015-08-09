class IOS::LoginPage < Calabash::Page
  include Calabash::IOS

  USERNAME_FIELD          = {id: 'icon-username-field'}
  PASSWORD_FIELD          = {id: 'icon-password-field'}
  LOGIN_BUTTON            = {class: 'WPNUXMainButton'}
  INFO_BUTTON             = {marked: 'Help'}
  SELF_HOSTED_SITE_BUTTON = {marked: 'Add Self-Hosted Site'}
  SELF_HOSTED_SITE_FIELD  = {id: 'icon-url-field'}


  def trait
    "WPNUXMainButton marked:'Sign In'"
  end

  def more_info
    tap(INFO_BUTTON)
  end

  def login(username, password)
    enter_username(username)
    enter_password(password)
    tap({id: 'icon-wp'})
    add_self_hosted_site(CREDENTIALS[:site])
    tap(LOGIN_BUTTON)
  end

  def enable_self_hosted_site
    toggle_self_hosted_site
    wait_for_view(SELF_HOSTED_SITE_FIELD)
  end

  private

  def enter_username(username)
    enter_text_in(USERNAME_FIELD, username)
  end

  def enter_password(password)
    enter_text_in(PASSWORD_FIELD, password)
  end

  def toggle_self_hosted_site
    tap(SELF_HOSTED_SITE_BUTTON)
  end

  def add_self_hosted_site(url)
    enable_self_hosted_site
    enter_text_in(SELF_HOSTED_SITE_FIELD, url)
  end
end
