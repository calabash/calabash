module Calabash
  module Android
    # @!visibility private
    module Build
      # @!visibility private
      class Application < Android::Application
        def initialize(application_path, options = {})
          super(application_path, nil, options)
        end
      end
    end
  end
end
