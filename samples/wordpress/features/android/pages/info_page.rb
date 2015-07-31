class Android::InfoPage < Calabash::Page
  include Calabash::Android

  def trait
    {id: 'help_button'}
  end

  def go_back_to_login_page
    go_back
  end
end