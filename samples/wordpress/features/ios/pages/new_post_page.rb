class IOS::NewPostPage < Calabash::Page
  include Calabash::IOS

  def trait
    {marked: 'Title'}
  end

  def add_data(title, content)
    wait_for_animations
    enter_text_in({marked: 'Title'}, title)
    enter_text_in({marked: 'Content'}, content)
    tap({marked: 'done'})
    wait_for_animations
  end

  def publish
    tap({marked: 'Publish'})
  end
end