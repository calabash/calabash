class Android::NewPostPage < Calabash::Page
  def trait
    {id: 'post_title'}
  end

  def add_data(title, content)
    cal.enter_text_in({id: 'post_title'}, title)
    cal.enter_text_in({id: 'post_content'}, content)
    cal_android.go_back
  end

  def publish
    cal.tap({id: 'menu_save_post'})
  end
end