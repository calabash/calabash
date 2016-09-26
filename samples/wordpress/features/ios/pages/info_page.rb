class IOS::InfoPage < Calabash::Page
  def trait
    "UINavigationBar id:'Support'"
  end

  def go_back_to_login_page
    cal_ios.wait_for_animations
    cal.tap({marked: 'Close'})
  end
end