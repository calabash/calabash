class Android::InfoPage < Calabash::Page
  def trait
    {id: 'help_button'}
  end

  def go_back_to_login_page
    cal_android.go_back
  end
end