require_relative 'view_post_page'

class IOS::EditPostPage < IOS::ViewPostPage
  def set_new_title(new_title)
    wait_for_animations
    clear_text_in({marked: 'Title'})
    enter_text(new_title)
    tap({marked: 'done'})
    wait_for_animations
  end

  def update
    tap({marked: 'Update'})
  end
end
