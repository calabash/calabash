require_relative 'view_post_page'

class IOS::EditPostPage < IOS::ViewPostPage
  def set_new_title(new_title)
    cal_ios.wait_for_animations
    # Animation causes the text field to change position,
    # so we can't use clear_text_in.
    cal.wait_for_view("UITextField marked:'Title'")
    cal.tap("UITextField marked:'Title'")
    cal.wait_for_keyboard
    cal_ios.wait_for_animations
    cal.clear_text
    cal.enter_text(new_title)
    cal.tap({marked: 'done'})
    cal_ios.wait_for_animations
  end

  def update
    cal.tap({marked: 'Update'})
  end
end
