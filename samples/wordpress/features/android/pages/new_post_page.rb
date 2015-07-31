class Android::NewPostPage < Calabash::Page
  include Calabash::Android

  def trait
    {id: 'post_title'}
  end

  def add_data(title, content)
    enter_text_in({id: 'post_title'}, title)
    enter_text_in({id: 'post_content'}, content)
    press_back_button
  end

  def publish
    tap({id: 'menu_save_post'})
  end
end