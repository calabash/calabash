class IOS::PostsPage < Calabash::Page
  def trait
    "UINavigationBar id:'Me'"
  end

  def sign_out
    cal.tap({marked: 'Me'})
    cal.tap({marked: 'Me'})
    cal.tap({marked: 'Edit'})
    cal.tap("UITableViewCellEditControl {accessibilityLabel BEGINSWITH 'Delete'}")
    cal_ios.wait_for_animations
    cal.tap("UIButtonLabel marked:'Remove'")
  end

  def goto_add_new_post
    cal_ios.wait_for_animations
    cal.tap({id: 'icon-tab-newpost'})
  end

  def view_posts
    cal_ios.wait_for_animations
    cal.tap({marked: 'Me'})
    cal_ios.wait_for_animations
    cal.tap({marked: 'Me'})
    cal_ios.wait_for_animations
    cal.tap("view marked:'Calabash Blog'")
    cal.tap({id: 'icon-menu-posts'})
  end

  def first_post_title
    posts[0]
  end

  def view_first_post_with_title(title)
    cal.wait_for(message: "Expected first post to have the title '#{@last_title}'. It had '#{title}'") do
      cal.page(PostsPage).first_post_title == title
    end

    cal_ios.wait_for_animations

    cal.tap("view marked:'#{title}' parent UITableViewCell index:0")
  end

  def delete_post_with_title(title)
    query = "view marked:'#{title}' parent UITableViewCell"

    cal.wait_for_view(query)

    if cal_ios.physical_device?
      # swipe-do-delete works on physical devices.
      cal.pan(query, percent(80, 50), percent(20, 50))

      cal_ios.wait_for_animations
      query = "UIButtonLabel marked:'Remove'"
      cal.wait_for_view(query)

      cal.tap(query)
      cal_ios.wait_for_animations
    else
      # but not on simulators
      cal.pan(query, percent(80, 50), percent(20, 50))
    end
  end

  private

  def posts
    cal.wait_for_view("UITableView")
    cal_ios.wait_for_animations

    # Some versions of iOS will return nil for empty text property;
    # some versions will return ''
    text = cal.query("UITableViewCell descendant label", :text).compact
    no_empties = text.map do |string|
      if string == ''
        nil
      else
        string
      end
    end.compact

    # Collect only the titles.
    no_empties.select.each_with_index { |elm, index| index.even? }
  end

end

