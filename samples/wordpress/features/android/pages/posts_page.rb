class Android::PostsPage < Calabash::Page
  include Calabash::Android

  def trait
    {id: 'posts'}
  end

  def sign_out
    tap({marked: 'More options'})
    tap({marked: 'Sign out'})
    tap("button marked:'Sign out'")
  end

  def goto_add_new_post
    tap({id: 'menu_new_post'})
  end

  def view_posts
    tap({marked: 'Posts, Open drawer'})
  end

  def first_post_title
    posts.first['text']
  end

  def view_first_post_with_title(title)
    wait_for(message: "Expected first post to have the title '#{@last_title}'. It had '#{title}'") do
      page(PostsPage).first_post_title == title
    end

    wait_for_no_views("android.widget.ProgressBar")

    tap("* id:'list' * id:'post_list_title' index:0")
  end

  private

  def posts
    wait_for_view("* id:'list'")
    wait_for_no_views("android.widget.ProgressBar")
    query("* id:'list' * id:'post_list_title'")
  end
end