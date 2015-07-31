class Android::EditPostPage < Calabash::Page
  include Calabash::Android

  def set_new_title(new_title)
    clear_text_in({id: 'post_title'})
    enter_text(new_title)
  end

  def update
    tap({id: 'menu_save_post'})
  end
end
