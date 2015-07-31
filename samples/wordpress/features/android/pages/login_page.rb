class Android::LoginPage < Calabash::Page
  include Calabash::Android

  USERNAME_FIELD          = {id: 'nux_username'}
  PASSWORD_FIELD          = {id: 'nux_password'}
  LOGIN_BUTTON            = {id: 'nux_sign_in_button'}
  INFO_BUTTON             = {id: 'info_button'}
  SELF_HOSTED_SITE_BUTTON = {id: 'nux_add_selfhosted_button'}
  SELF_HOSTED_SITE_FIELD  = {id: 'nux_url'}


  def trait
    "android.widget.TextView text:'Sign in'"
  end

  def more_info
    tap(INFO_BUTTON)
  end

  def login(username, password)
    enter_username(username)
    enter_password(password)
    dismiss_keyboard
    add_self_hosted_site(CREDENTIALS[:site])
    tap(LOGIN_BUTTON)
    wait_for_no_views('android.widget.ProgressBar')
  end

  def expect_login_error_message
    expect_view({text: 'The username or password you entered is incorrect'})
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
