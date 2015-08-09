module Calabash
  module IOS
    # @!visibility private
    # Contains methods for interacting with the iPad.
    module IPadMixin

      # @!visibility private
      # Provides methods to interact with the 1x and 2x buttons that appear
      # when an iPhone-only app is emulated on an iPad.  Calabash cannot
      # interact with these apps in 2x mode because the touch coordinates
      # cannot be reliably translated from normal iPhone dimensions to the
      # emulated dimensions.
      #
      # On iOS < 7, an app _remembered_ its last 1x/2x scale so when it
      # reopened the previous scale would be the same as when it closed.  This
      # meant you could manually set the scale once to 1x and never have to
      # interact with the scale button again.
      #
      # On iOS > 7, the default behavior is that all emulated apps open at 2x
      # regardless of their previous scale.
      #
      # @note In order to use this class, you must allow Calabash to launch
      #  your app with instruments.
      class Emulation

        # @!visibility private
        #
        # Maintainers:  when adding a localization, please notice that
        # the keys and values are semantically reversed.
        #
        # you should read the hash as:
        #
        # ```
        # :emulated_1x <= what button is showing when the app is emulated at 2X?
        # :emulated_2x <= what button is showing when the app is emulated at 1X?
        # ```
        #
        # @todo Once we have localizations wired up, we can use these keys
        #
        # These pull requests describe how to find a key/value pairs from the
        # on-disk accessibility bundles for _keyboards_ but we can use the same
        # strategy to look up the Zoom button localizations.
        #
        # * https://github.com/calabash/run_loop/pull/197
        # * https://github.com/calabash/calabash-ios-server/pull/221
        #
        #
        #  fullscreen.zoom => 2x => 'Switch to full screen mode'
        #  normal.zoom => 1x => 'Switch to normal mode'
        #
        #  # We will still need query windows.
        #  uia("UIATarget.localTarget().frontMostApp().windows()[2].elements()[0].label()")
        IPAD_1X_2X_BUTTON_LABELS = {
              :en => {:emulated_1x => '2X',
                      :emulated_2x => '1X'}
        }

        # @!visibility private
        # @!attribute [r] scale
        # The current 1X or 2X scale represented as a Symbol.
        #
        # @return [Symbol] Returns this emulation's scale.  Will be one of
        # `{:emulated_1x | :emulated_2x}`.
        attr_reader :scale

        # @!visibility private
        # @!attribute [r] lang_code
        # The Apple compatible language code for determining the accessibility
        # label of the 1X and 2X buttons.
        #
        # @return [Symbol] Returns the language code of this emulation.
        attr_reader :lang_code

        # @!visibility private
        # @!attribute [r] device
        # A handle on the default device.
        attr_reader :device

        # @!visibility private
        # A private instance variable for storing this emulation's 1X/2X button
        # names.  The value will be set at runtime based on the language code
        # that is passed the initializer.
        @button_names_hash = nil

        # @!visibility private
        # Creates a new Emulation.
        # @param [Symbol] lang_code an Apple compatible language code
        # @return [Emulation] Returns an emulation that is ready for action!
        def initialize (device, lang_code=:en)
          @button_names_hash = IPAD_1X_2X_BUTTON_LABELS[lang_code]
          if @button_names_hash.nil?
            raise "could not find 1X/2X buttons for language code '#{lang_code}'"
          end

          @device = device
          @lang_code = lang_code
          @scale = _internal_ipad_emulation_scale
        end

        # @!visibility private
        def tap_ipad_scale_button
          key = @scale
          name = @button_names_hash[key]

          query_args =
          [
               [
                 :view, {:marked => "#{name}"}
               ]
          ]

          device.uia_query_then_make_javascript_calls(:queryElWindows, query_args, :tap)
        end

        private

        # @!visibility private
        def _internal_ipad_emulation_scale
          hash = @button_names_hash
          val = nil
          hash.values.each do |button_name|
            query_args =
                  [
                        :view, {:marked => button_name}
                  ]

            button_exists = device.uia_serialize_and_call(:queryElWindows,
                                                          query_args)
            if button_exists
              result = device.uia_query_then_make_javascript_calls(:queryElWindows,
                                                                   [query_args],
                                                                   :name)
              if result == button_name
                val = button_name
                break
              end
            end
          end

          if val.nil?
            raise "Could not find iPad scale button with '#{hash.values}'"
          end

          if val == hash[:emulated_1x]
            :emulated_1x
          elsif val == hash[:emulated_2x]
            :emulated_2x
          else
            raise "Unrecognized emulation scale '#{val}'"
          end
        end
      end

      # @!visibility private
      # Ensures that iPhone apps emulated on an iPad are displayed at scale.
      #
      # @note It is recommended that clients call this `ensure_ipad_emulation_1x`
      #  instead of this method.
      #
      # @note If this is not an iPhone app emulated on an iPad, then calling
      #  this method has no effect.
      #
      # @note In order to use this method, you must allow Calabash to launch
      #  your app with instruments.
      #
      # Starting in iOS 7, iPhone apps emulated on the iPad always launch at 2x.
      # calabash cannot currently interact with such apps in 2x mode (trust us,
      # we've tried).
      #
      # @see #ensure_ipad_emulation_1x
      #
      # @param [Symbol] scale the desired scale - must be `:emulated_1x` or
      #  `:emulated_2x`
      #
      # @param [Hash] opts optional arguments to control the interaction with
      #  the 1X/2X buttons
      #
      # @option opts [Symbol] :lang_code (:en) an Apple compatible
      #  language code
      # @option opts [Symbol] :wait_after_touch (0.4) how long to
      #  wait _after_ the scale button is touched
      #
      # @return [void]
      #
      # @raise [RuntimeError] If the app was not launched with instruments.
      # @raise [RuntimeError] If an invalid `scale` is passed.
      # @raise [RuntimeError] If an unknown language code is passed.
      # @raise [RuntimeError] If the scale button cannot be touched.
      def ensure_ipad_emulation_scale(scale, opts={})
        return unless iphone_app_emulated_on_ipad?

        allowed = [:emulated_1x, :emulated_2x]
        unless allowed.include?(scale)
          raise "Scale '#{scale}' is not one of '#{allowed}' allowed args"
        end

        default_opts = {:lang_code => :en,
                        :wait_after_touch => 0.4}
        merged_opts = default_opts.merge(opts)

        obj = Emulation.new(self, merged_opts[:lang_code])

        actual_scale = obj.scale

        if actual_scale != scale
          obj.tap_ipad_scale_button
        end

        sleep(merged_opts[:wait_after_touch])
      end

      # @!visibility private
      # Ensures that iPhone apps emulated on an iPad are displayed at `1X`.
      #
      # @note If this is not an iPhone app emulated on an iPad, then calling
      #  this method has no effect.
      #
      # @note In order to use this method, you must allow Calabash to launch
      #  your app with instruments.
      #
      # Starting in iOS 7, iPhone apps emulated on the iPad always launch at 2x.
      # calabash cannot currently interact with such apps in 2x mode (trust us,
      # we've tried).
      #
      # @param [Hash] opts optional arguments to control the interaction with
      #  the 1X/2X buttons
      #
      # @option opts [Symbol] :lang_code (:en) an Apple compatible
      #  language code
      # @option opts [Symbol] :wait_after_touch (0.4) how long to
      #  wait _after_ the scale button is touched
      #
      # @return [void]
      #
      # @raise [RuntimeError] If the app was not launched with instruments.
      # @raise [RuntimeError] If an unknown language code is passed.
      # @raise [RuntimeError] If the scale button cannot be touched.
      def ensure_ipad_emulation_1x(opts={})
        ensure_ipad_emulation_scale(:emulated_1x, opts)
      end

      private
      # @!visibility private
      # Ensures iPhone apps running on an iPad are emulated at 2X
      #
      # You should never need to call this function - Calabash cannot interact
      # with iPhone apps emulated on the iPad in 2x mode.
      def _ensure_ipad_emulation_2x(opts={})
        ensure_ipad_emulation_scale(:emulated_2x, opts)
      end
    end
  end
end
