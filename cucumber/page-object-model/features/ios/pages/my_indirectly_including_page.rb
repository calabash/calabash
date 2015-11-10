module CalabashIOSIncluder
  include Calabash::IOS
end

class IOS::MyIndirectlyIncludingPage < Calabash::Page
  include ::CalabashIOSIncluder
end
