module Calabash
  # Runtime defaults.
  module Defaults
    # Get the default server. The default server is the test-server
    # of the `#default_device`.
    #
    # @example
    #  # Setup the two apps we are going to test
    #  app1 = Calabash::Android::Application.new(app1_path, app1_test_server_path)
    #  app2 = Calabash::Android::Application.new(app2_path, app2_test_server_path)
    #
    #  # Ensure they are installed
    #  ensure_app_installed(app1)
    #  ensure_app_installed(app2)
    #
    #  # Set up the servers of the apps. Notice that the second app has to use a
    #  # different port for them to be able to run at the same time.
    #  app1_server = Calabash.default_server
    #  app2_server = Calabash::Server.new(app1_server.endpoint, app1_server.test_server_port + 1)
    #
    #  # Start the first app
    #  start_app(app1)
    #  # Interact with the first app
    #  tap("something on app 1")
    #
    #  # Start the second app
    #  Calabash.default_server = app2_server
    #  start_app(app2)
    #
    #  # Interact with the second app
    #  tap("something on app 2")
    #
    #  # Resume the first app
    #  Calabash.default_server = app1_server
    #  resume_app(app1)
    #
    #  # Interact with the first app again
    #  tap("something on app 1")
    #
    # @raise [RuntimeError] If default device is not set
    def default_server
      if default_device.nil?
        raise 'No default device set'
      end

      default_device.server
    end

    # Set the default server.
    #
    # @see Calabash::Defaults#default_server
    # @raise [RuntimeError] If default device is not set
    def default_server=(server)
      default_device.change_server(server)
    end
  end
end
