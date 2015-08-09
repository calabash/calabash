require_relative 'view_post_page'

class IOS::EditPostPage < IOS::ViewPostPage
  def set_new_title(new_title)
    wait_for_animations
    # Animation causes the text field to change position,
    # so we can't use clear_text_in.
    wait_for_view("UITextField marked:'Title'")
    tap("UITextField marked:'Title'")
    wait_for_keyboard
    wait_for_animations
    clear_text
    enter_text(new_title)
    tap({marked: 'done'})
    wait_for_animations
  end

  def update
    tap({marked: 'Update'})
  end
end
