class Android::EditPostPage < Calabash::Page
  def set_new_title(new_title)
    cal.clear_text_in({id: 'post_title'})
    cal.enter_text(new_title)
  end

  def update
    cal.tap({id: 'menu_save_post'})
  end
end
