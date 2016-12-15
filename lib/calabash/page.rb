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
  class Page
    # @!visibility private
    def self.inherited(subclass)
      # Define the page into global scope
      full_name = subclass.name

      if full_name == 'IOS' || full_name == 'Android'
        raise "Invalid page name '#{full_name}'"
      end

      os_scope = full_name.split('::').first

      if os_scope == 'IOS' || os_scope == 'Android'
        page_name = full_name.split('::', 2).last

        unless Calabash.is_defined?(page_name)
          scopes = page_name.split('::')

          previous_scope = ''

          scopes[0..-2].each do |scope|
            old_scope = Calabash.recursive_const_get("Object::#{os_scope}#{previous_scope}")
            new_scope = Calabash.recursive_const_get("Object#{previous_scope}")

            old_const = old_scope.const_get(scope.to_sym)

            if new_scope.const_defined?(scope.to_sym)
              new_scope.send(:remove_const, scope.to_sym)
            end

            new_scope.const_set(scope.to_sym, old_const.class.allocate)

            previous_scope << "::#{scope}"
          end

          simple_page_name = page_name.split('::').last.to_sym
          new_scope = Calabash.recursive_const_get("Object#{previous_scope}")

          unless new_scope.const_defined?(simple_page_name, false)
            clz = Class.new(StubPage)
            new_scope.const_set(simple_page_name, clz)
          end
        end
      end
    end

    private_class_method :new

    # @!visibility private
    def initialize(world)
      @world = world
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
