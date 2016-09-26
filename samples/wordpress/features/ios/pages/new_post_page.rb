class IOS::NewPostPage < Calabash::Page
  def trait
    {marked: 'Title'}
  end

  def add_data(title, content)
    cal_ios.wait_for_animations
    cal.enter_text_in({marked: 'Title'}, title)
    cal.enter_text_in({marked: 'Content'}, content)
    cal.tap({marked: 'done'})
    cal_ios.wait_for_animations
  end

  def publish
    cal.tap({marked: 'Publish'})
    cal_ios.wait_for_no_network_indicator
  end
end
