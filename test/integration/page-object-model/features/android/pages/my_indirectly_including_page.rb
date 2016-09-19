module CalabashAndroidIncluder
  include Calabash::Android
end

class Android::MyIndirectlyIncludingPage < Calabash::Page
  include CalabashAndroidIncluder
end
