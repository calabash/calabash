module Calabash
  module Android
    module Build
      class Application < Android::Application
        def initialize(application_path, options = {})
          super(application_path, nil, options)
        end
      end
    end
  end
end