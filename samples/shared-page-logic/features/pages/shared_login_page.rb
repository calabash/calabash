class SharedLoginPage < Calabash::Page
  def login(username, password)
    enter_text_in(username_field, username)
    enter_text_in(password_field, password)
    cal.tap(login_button)
  end

  private

  def username_field
    abstract_method!
  end

  def password_field
    abstract_method!
  end

  def login_button
    abstract_method
  end
end