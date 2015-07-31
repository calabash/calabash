class IOS::InfoPage < Calabash::Page
  include Calabash::IOS

  def trait
    "UINavigationBar id:'Support'"
  end

  def go_back_to_login_page
    wait_for_animations
    tap({marked: 'Close'})
  end
end