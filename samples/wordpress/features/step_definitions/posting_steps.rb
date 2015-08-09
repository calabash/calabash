Then(/^I should be able to add a new post$/) do
  page(PostsPage).goto_add_new_post
end

And(/^give it a title and some content$/) do
  data = Posts.generate_random_post_data

  @last_title = data[:title]
  @last_content = data[:content]

  page(NewPostPage).add_data(@last_title, @last_content)
end

When(/^I publish the post$/) do
  page(NewPostPage).publish
end

Then(/^I should see the new post in the list of posts$/) do
  title = page(PostsPage).first_post_title

  wait_for(message: "Expected first post to have the title '#{@last_title}'. It had '#{title}'") do
    page(PostsPage).first_post_title == @last_title
  end
end

Given(/^I have added a post$/) do
  page(PostsPage).goto_add_new_post

  data = Posts.generate_random_post_data

  @last_title = data[:title]
  @last_content = data[:content]

  page(NewPostPage).await
  page(NewPostPage).add_data(@last_title, @last_content)
  page(NewPostPage).publish
end

When(/^I view that post$/) do
  page(PostsPage).view_first_post_with_title(@last_title)
  page(ViewPostPage).await
end

Then(/^I should show the title and content I gave it$/) do
  title = page(ViewPostPage).title

  if title != @last_title
    fail "Expected current post to have the title '#{@last_title}'. It had '#{title}'"
  end

  content = page(ViewPostPage).content

  if content != @last_content
    fail "Expected current post to have the title '#{@last_content}'. It had '#{content}'"
  end
end

Then(/^I should be able to delete it$/) do
  page(ViewPostPage).delete
end

And(/^it should not appear in the list of posts$/) do
  if page(PostsPage).first_post_title == @last_title
    fail "The post with the title '#{@last_title}' still appeared"
  end
end

Then(/^I should be able to edit it$/) do
  if android?
    page(ViewPostPage).edit
  end
end

When(/^I give it a new title$/) do
  data = Posts.generate_random_post_data

  @last_title = data[:title]

  page(EditPostPage).set_new_title(@last_title)
  page(EditPostPage).update
end

Then(/^it should appear with the changes in my list of posts$/) do
  title = page(PostsPage).first_post_title

  wait_for(message: "Expected first post to have the title '#{@last_title}'. It had '#{title}'") do
    page(PostsPage).first_post_title == @last_title
  end
end

When(/^I try to swipe-to-delete that post on a simulator$/) do
  page(PostsPage).delete_post_with_title(@last_title)
end

Then(/^I expect an error about a broken Apple API$/) do
  # See the Step above.
end

But(/^I can delete that post on a device$/) do
  page(PostsPage).delete_post_with_title(@last_title)
end
