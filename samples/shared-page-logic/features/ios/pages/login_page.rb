class IOS::LoginPage < SharedLoginPage
  private

  def username_field
    "* marked:'i_username'"
  end

  def password_field
    "* marked:'i_password'"
  end

  def login_button
    "UIButton marked:'login'"
  end
end
