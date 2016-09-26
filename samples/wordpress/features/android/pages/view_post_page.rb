class Android::ViewPostPage < Calabash::Page
  def trait
    {id: 'viewPostWebView'}
  end

  def title
    cal.wait_for_view({id: 'postTitle'})['text']
  end

  def content
    cal.wait_for_view({id: 'viewPostWebView', css:'body'})['textContent']
  end

  def delete
    cal.tap({id: 'deletePost'})
    cal.tap({marked: 'Yes'})
  end

  def edit
    cal.tap({id: 'editPost'})
  end
end
