class IOS::AlertPage < Calabash::Page
  include Calabash::IOS

  def trait
    "UIImageView id:'icon-alert'"
  end

  def expect_login_error_message
    expect_view({text: "Sorry, we can't log you in."})
  end
end
