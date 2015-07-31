class Android::ViewPostPage < Calabash::Page
  include Calabash::Android

  def trait
    {id: 'viewPostWebView'}
  end

  def title
    wait_for_view({id: 'postTitle'})['text']
  end

  def content
    wait_for_view({id: 'viewPostWebView', css:'body'})['textContent']
  end

  def delete
    tap({id: 'deletePost'})
    tap({marked: 'Yes'})
  end

  def edit
    tap({id: 'editPost'})
  end
end
