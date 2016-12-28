module Calabash
  # A base class for the Page Object Model (POM) or Page Object Pattern.
  #
  # We recommend the POM for testing cross-platform apps.
  #
  # @example
  #  # You must have a page for the platforms you target
  #  class Android::MyPage < Calabash::Page
  #    # ...
  #  end
  #
  #  cal.page(MyPage).await
  #
  # We have a great examples of using the POM in the Calabash 2.0 repository.
  #   * https://github.com/calabash/calabash/tree/develop/samples/shared-page-logic
  class AbstractPage
    # @!visibility private
    def self.inherited(subclass)
      # We have been invoked because of our own 'inherited'
      if subclass.superclass.name == "Calabash::AbstractPage"
        # Add Android and IOS subclasses to our direct subclass
        @@_inheriting = true
        subclass.const_set(:Android, Class.new(subclass) do
        end)
        subclass.const_set(:IOS, Class.new(subclass) do
        end)
        @@_inheriting = false
      elsif !((subclass.name == "Android" || subclass.name == "IOS") &&
          subclass.superclass && subclass.superclass.superclass.name == "Calabash::AbstractPage") &&
          !@@_inheriting

        raise TypeError, ["#{subclass} cannot inherit from #{subclass.superclass}.",
                          " Can only inherit directly from Calabash::AbstractPage,",
                          " or from platform-specific implementations",
                          " #{subclass}::Android and #{subclass}::IOS"].join("")
      end
    end

    def self.new(*args)
      if name == "Calabash::AbstractPage"
        raise "Cannot instantiate a Calabash::AbstractPage, inherit from this class"
      end

      # We are the direct subclass of AbstractPage, we should instantiate the platform-specific page
      if superclass.name == "Calabash::AbstractPage"
        if cal.android?
          return const_get(:Android).new(*args)
        elsif cal.ios?
          return const_get(:IOS).new(*args)
        else
          raise "Unable to instantiate #{self}, cannot detect the current platform"
        end
      end

      instance = allocate
      # Freeze the instance
      instance.freeze
      instance.send(:initialize, *args)
      instance
    end

    # @!visibility private
    def initialize
    end

    # A query that identifies your page. This method is used by
    # {Calabash::Page#await await}.
    #
    # @example
    #  class HomePage < Calabash::Page
    #    def trait
    #      {id: 'home'}
    #    end
    #  end
    #
    #  cal.page(HomePage).await # Uses `trait`
    #
    # @return [String, Hash, Calabash::Query] A query identifying the page.
    def trait
      raise 'Implement your own trait'
    end

    # Waits for the view identified by the page {Calabash::Page#trait trait} to
    # appear.
    #
    # @note If you need a more precise waiting method for a page, then
    #  just overwrite this method.
    #
    # @param [Number] timeout (default: {Calabash::Wait.default_options
    #  Calabash::Wait.default_options[:timeout]}) The time to continuously
    #  query before failing.
    # @raise [Calabash::Wait::UnexpectedMatchError] if no view matching
    #  {Calabash::Page#trait trait} is found within `timeout`.
    def await(timeout: Calabash::Wait.default_options[:timeout])
      timeout_message = lambda do |wait_options|
        "Timed out waiting for page #{self.class}: Waited #{wait_options[:timeout]} seconds for trait #{trait} to match a view"
      end

      cal.wait_for_view(trait, timeout: timeout, timeout_message: timeout_message)
    end

    # @!visibility private
    class StubPage

    end
  end
end
