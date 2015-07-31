class IOS::PostsPage < Calabash::Page
  include Calabash::IOS

  def trait
    "UINavigationBar id:'Me'"
  end

  def sign_out
    tap({marked: 'Me'})
    tap({marked: 'Me'})
    tap({marked: 'Edit'})
    tap("UITableViewCellEditControl {accessibilityLabel BEGINSWITH 'Delete'}")
    tap("UIButtonLabel marked:'Remove'")
  end

  def goto_add_new_post
    wait_for_animations
    tap({id: 'icon-tab-newpost'})
  end

  def view_posts
    wait_for_animations
    tap({marked: 'Me'})
    wait_for_animations
    tap({marked: 'Me'})
    wait_for_animations
    tap("WPBlogTableViewCell UITableViewLabel")
    tap({id: 'icon-menu-posts'})
  end

  def first_post_title
    posts[1]['text']
  end

  def view_first_post_with_title(title)
    wait_for(message: "Expected first post to have the title '#{@last_title}'. It had '#{title}'") do
      page(PostsPage).first_post_title == title
    end

    wait_for_animations

    tap("UITableViewWrapperView UITableViewCellContentView UILabel index:1")
  end

  private

  def posts
    wait_for_view("UITableViewWrapperView")
    wait_for_animations
    query("UITableViewWrapperView UITableViewCellContentView UILabel")
  end
end