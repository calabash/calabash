class Android::PostsPage < Calabash::Page
  def trait
    {id: 'posts'}
  end

  def sign_out
    cal.tap({marked: 'More options'})
    cal.tap({marked: 'Sign out'})
    cal.tap("button marked:'Sign out'")
  end

  def goto_add_new_post
    cal.tap({id: 'menu_new_post'})
  end

  def view_posts
    cal.tap({marked: 'Posts, Open drawer'})
  end

  def first_post_title
    posts.first['text']
  end

  def view_first_post_with_title(title)
    cal.wait_for(message: "Expected first post to have the title '#{@last_title}'. It had '#{title}'") do
      page(PostsPage).first_post_title == title
    end

    cal.wait_for_no_views("android.widget.ProgressBar")

    cal.tap("* id:'list' * id:'post_list_title' index:0")
  end

  private

  def posts
    cal.wait_for_view("* id:'list'")
    cal.wait_for_no_views("android.widget.ProgressBar")
    cal.query("* id:'list' * id:'post_list_title'")
  end
end