class ExpandedPage < Calabash::Page

end

class Android::MyIndirectlyInheritingPage < ExpandedPage
  include Calabash::Android
end
