module Calabash
  module Operations

    # @todo Needs docs!
    def query(query, *args)
      Calabash::Device.default.map_route(query, :query, *args)
    end

    # Escapes single quotes in `string`.
    #
    # @example
    #   > escape_quotes("Let's get this done.")
    #   => "Let\\'s get this done."
    # @param [String] string The string to escape.
    # @return [String] A string with its single quotes properly escaped.
    def escape_single_quotes(string)
      string.gsub("'", "\\\\'")
    end

    # @!visibility private
    def _start_app(application, options={})
      test_options = options.dup

      Calabash::Device.default.start_app(application, test_options)
    end

    # @!visibility private
    def _stop_app
      Calabash::Device.default.stop_app
    end

    # @!visibility private
    def _install_app(path_or_application)
      Device.default.install_app(path_or_application)
    end

    # @!visibility private
    def _ensure_app_installed(path_or_application)
      Device.default.ensure_app_installed(path_or_application)
    end

    # @!visibility private
    def _uninstall_app(path_or_application)
      Device.default.uninstall_app(path_or_application)
    end

    # @!visibility private
    def _clear_app_data(path_or_application)
      Device.default.clear_app_data(path_or_application)
    end
  end
end
