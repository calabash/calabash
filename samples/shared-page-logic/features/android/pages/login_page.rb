class Android::LoginPage < SharedLoginPage
  include Calabash::Android

  private

  def username_field
    "* marked:'a_username'"
  end

  def password_field
    "* marked:'a_password'"
  end

  def login_button
    "android.widget.Button marked:'login'"
  end
end
