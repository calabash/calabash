module Login
  class << self
    include Calabash
  end

  def self.ensure_logged_in
    # We set the variable @logged_in to false when we reset in hooks.rb
    unless @logged_in
      login
    end
  end

  def self.login
    page(LoginPage).await(message: 'Can only sign in from login page')

    credentials = CREDENTIALS[:valid_user]
    page(LoginPage).login(credentials[:username], credentials[:password])

    page(PostsPage).await
    @logged_in = true

    # The menu is expanded the first time logging in on Android.
    # Some other view is shown on iOS.
    page(PostsPage).view_posts
  end
end

module Posts
  class << self
    include Calabash
  end

  def self.generate_random_post_data
    letters = ('a'..'z').to_a
    title = (0..20).map{letters[rand(letters.length)]}.join
    content = (0..30).map{letters[rand(letters.length)]}.join

    {title: title, content: content}
  end
end
