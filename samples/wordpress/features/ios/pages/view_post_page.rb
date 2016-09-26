class IOS::ViewPostPage < Calabash::Page
  def trait
    {id: 'icon-posts-editor-preview'}
  end

  def title
    cal.wait_for_view({marked: 'Title'})['text']
  end

  def content
    cal.wait_for_view({marked: 'Content'})['text']
  end
end
