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
    wait_for_animations
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
    tap("view marked:'Calabash Blog'")
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

    tap("view marked:'#{title}' parent UITableViewCell index:0")
  end

  def delete_post_with_title(title)
    query = "view marked:'#{title}' parent UITableViewCell"

    wait_for_view(query)

    if physical_device?
      # swipe-do-delete works on physical devices.
      pan(query, percent(80, 50), percent(20, 50))

      wait_for_animations
      query = "UIButtonLabel marked:'Remove'"
      wait_for_view(query)

      tap(query)
      wait_for_animations
    else
      # but not on simulators
      begin
        pan(query, percent(80, 50), percent(20, 50))
      rescue RuntimeError => e
        unless e.message[/Apple's public UIAutomation API `dragInsideWithOptions`/][0]
          message = [
            "When trying to swipe-to-delete a post on an iOS Simulator.",
            "Expected: error about a broken UIAutomation API.",
            "     Got: #{e}",
          ].join("\n")
          raise message
        end
      end
    end
  end

  private

  def posts
    wait_for_view("UITableViewWrapperView")
    wait_for_animations
    query("UITableViewWrapperView UITableViewCellContentView UILabel")
  end
end
