module Calabash
  module IOS

    # A representation of the embedded Calabash iOS server.
    class Server < ::Calabash::Server

      # Returns the default server.
      #
      # You can set the default server by setting the `CAL_ENDPOINT` environment
      # variable.  If this value is not set, the default server will be
      # `http://localhost:37265`.
      #
      # **IMPORTANT**
      #
      # You must include http:// and the port number when setting the
      # `CAL_ENDPOINT` variable.
      #
      # ### Physical Devices
      #
      # When targeting a physical device, you _must_ set the `CAL_ENDPOINT`
      # environment variable.  Your device must be on the same network as the
      # host machine.  You can find your device's IP address the Settings.app.
      #
      #     Settings.app > WiFi > touch the (i)nfo
      #     disclosure button of the network you are
      #     connected to.
      #
      # ### Pro Tip:  Name your devices.
      #
      # The Calabash iOS Server is a Bonjour web service. You can avoid the
      # hassle of determining a device's IP address by naming your devices.  The
      # names should not have spaces or characters that cannot be displayed
      # plainly in a URL.
      #
      # Suppose you have 3 devices:  an iPad Mini Retina, an iPhone 4S, and an
      # iPhone 6.
      #
      # | Device | Name | IP |
      # |--------|------|----|
      # | iPad   | ipad-mini | CAL_ENDPOINT=http://ipad-mini.local:37265 |
      # | iPhone 4S     | iphone4s  | CAL_ENDPOINT=http://iphone4s.local:37265 |
      # | iPhone 6      | iphone6   | CAL_ENDPOINT=http://iphone6.local:37265 |
      #
      # ### Pro Tip: Changing the Calabash server port.
      #
      # You can change the port number of the server by adding
      # `CalabashServerPort` to your app's Info plist.
      #
      #      CalabashServerPort NSNumber 9999
      #
      # ### Pro Tip: Share your wired connection
      #
      # https://github.com/calabash/calabash/wiki/iOS:-Improving-Network-Stability
      #
      # @return [Calabash::IOS::Server] The Calabash iOS server that is
      #  embedded in your app.
      def self.default
        endpoint = Environment::DEVICE_ENDPOINT
        Server.new(endpoint)
      end

      # Is this server running on the host machine?
      #
      # Apps running on the iOS Simulator are running on localhost.
      #
      # @return [Boolean] Returns true if the server hostname resolves to
      #  localhost.
      def localhost?
        endpoint.hostname == 'localhost' || endpoint.hostname == '127.0.0.1'
      end
    end
  end
end
