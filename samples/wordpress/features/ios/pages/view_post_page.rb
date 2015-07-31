class IOS::ViewPostPage < Calabash::Page
  include Calabash::IOS

  def trait
    {id: 'icon-posts-editor-preview'}
  end

  def title
    wait_for_view({marked: 'Title'})['text']
  end

  def content
    wait_for_view({marked: 'Content'})['text']
  end

  def delete
    fail("This screen does not have a delete key")
  end
end
