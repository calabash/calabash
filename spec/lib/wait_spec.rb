describe Calabash::Wait do
  let(:dummy) {Class.new {include Calabash::Wait; def screenshot_embed; end; def query(_); end}.new}

  after do
    hide_const('Calabash::Wait::Timeout')
  end

  describe 'default_options' do
    it 'should have the correct default values' do
      wait_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'wait.rb')
      load wait_file

      default_options = Calabash::Wait.default_options

      expect(default_options[:timeout]).to eq(Calabash::Environment::WAIT_TIMEOUT)
      expect(default_options[:message].call({timeout: 10})).to eq("Timed out after waiting for 10 seconds...")
      expect(default_options[:retry_frequency]).to eq(0.3)
      expect(default_options[:exception_class]).to eq(Calabash::Wait::TimeoutError)
      expect(default_options[:screenshot_on_error]).to eq(true)

      load wait_file
    end

    it 'should be able to set it' do
      wait_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'wait.rb')

      Calabash::Wait.default_options[:timeout] = 60
      Calabash::Wait.default_options[:message] = 'test'
      Calabash::Wait.default_options[:retry_frequency] = 1
      Calabash::Wait.default_options[:exception_class] = String
      Calabash::Wait.default_options[:screenshot_on_error] = false

      default_options = Calabash::Wait.default_options

      expect(default_options[:timeout]).to eq(60)
      expect(default_options[:message]).to eq('test')
      expect(default_options[:retry_frequency]).to eq(1)
      expect(default_options[:exception_class]).to eq(String)
      expect(default_options[:screenshot_on_error]).to eq(false)

      load wait_file
    end
  end

  describe '#default_options' do
    it 'should return the default options' do
      wait_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'wait.rb')
      default_options = {a: :b}

      Calabash::Wait.class_variable_set(:@@default_options, default_options)

      expect(Calabash::Wait.default_options).to eq(default_options)

      load wait_file
    end
  end

  describe '#default_options=' do
    it 'should set the default options' do
      wait_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash', 'wait.rb')
      default_options = {c: :d}

      Calabash::Wait.default_options = default_options

      expect(Calabash::Wait.default_options).to eq(default_options)

      load wait_file
    end
  end

  describe '#with_timeout' do
    it 'should fail when given the wrong parameters' do
      expect{dummy.with_timeout(5, 'msg')}.to raise_error(ArgumentError, 'You must provide a block')
      expect{dummy.with_timeout(0, '')}.to raise_error(ArgumentError, 'You must provide a timeout message')
      expect{dummy.with_timeout(0, 'msg') {}}.to raise_error(ArgumentError, 'Timeout cannot be 0')
    end

    it 'should raise the right timeout message' do
      stub_const('Calabash::Wait::Timeout', AlwaysRaiseTimeout)

      expect(dummy).to receive(:fail).with(Calabash::Wait::TimeoutError, 'message')

      dummy.with_timeout(10, 'message') {}

      expect(dummy).to receive(:fail).with(Calabash::Wait::TimeoutError, '10 message')

      dummy.with_timeout(10, lambda {|options| "#{options[:timeout]} message"}) {}
    end

    it 'should not fail if the block does not exceed timeout' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)

      expect(dummy).not_to receive(:fail)

      dummy.with_timeout(10, 'message') {}
    end

    it 'should invoke the block once' do
      dummy.define_singleton_method(:test) {}

      expect(dummy).to receive(:test).once

      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)

      dummy.with_timeout(10, 'message') {dummy.test}
    end
  end

  describe '#wait_for' do
    it 'should invoke with_timeout' do
      my_error = Class.new(RuntimeError)

      expect(dummy).to receive(:with_timeout).with(10, 'msg', my_error)

      dummy.wait_for('msg', timeout: 10, exception_class: my_error, retry_frequency: 0)
    end

    it 'should invoke the block given in with_timeout continuously until it returns truthy' do
      my_error = Class.new(RuntimeError)
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      dummy.define_singleton_method(:test) do
        @i ||= 0

        @i += 1

        @i == 10
      end

      expect(dummy).to receive(:test).exactly(10).times.and_call_original

      dummy.wait_for('msg', timeout: 10, exception_class: my_error, retry_frequency: 0) do
        dummy.test
      end
    end

    it 'should sleep between calls' do
      my_error = Class.new(RuntimeError)
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      dummy.define_singleton_method(:test) do
        @i ||= 0

        @i += 1

        @i == 10
      end

      expect(dummy).to receive(:test).exactly(10).times.and_call_original
      expect(dummy).to receive(:sleep).exactly(9).times.with(2)

      dummy.wait_for('msg', timeout: 10, exception_class: my_error, retry_frequency: 2) do
        dummy.test
      end
    end

    it 'should use defaults' do
      my_error = Class.new(RuntimeError)
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      dummy.define_singleton_method(:test) do
        @i ||= 0

        @i += 1

        @i == 10
      end
      Calabash::Wait.default_options[:exception_class] = my_error
      Calabash::Wait.default_options[:retry_frequency] = 5

      expect(dummy).to receive(:test).exactly(10).times.and_call_original
      expect(dummy).to receive(:sleep).exactly(9).times.with(5)

      dummy.wait_for('msg', timeout: 10) do
        dummy.test
      end
    end

    it 'should return the value of the block given' do
      dummy.define_singleton_method(:test) {'truthy'}

      expect(dummy.wait_for('msg', timeout: 10) do
        dummy.test
      end).to eq('truthy')
    end
  end

  describe '#fail' do
    it 'should fail with a given message and error' do
      my_error = Class.new(RuntimeError)
      my_message = 'My message'

      expect{dummy.fail(my_message)}.to raise_error(RuntimeError, my_message)
      expect{dummy.fail(my_error, my_message)}.to raise_error(my_error, my_message)
    end

    it 'should take a screenshot if screenshot_on_error is true' do
      Calabash::Wait.default_options[:screenshot_on_error] = true
      expect(dummy).to receive(:screenshot_embed).once
      expect{dummy.fail('Message')}.to raise_error
    end

    it 'should not take a screenshot if screenshot_on_error is false' do
      Calabash::Wait.default_options[:screenshot_on_error] = false
      expect(dummy).not_to receive(:screenshot_embed)
      expect{dummy.fail('Message')}.to raise_error
    end
  end

  describe 'view_exists?' do
    it 'should execute the given query' do
      query = 'my query'

      expect(dummy).to receive(:query).with(query).and_return([{}])

      dummy.view_exists?(query)
    end

    it 'should return false if the query matches no views' do
      query = 'my query'

      expect(dummy).to receive(:query).with(query).and_return([])

      expect(dummy.view_exists?(query)).to eq(false)
    end

    it 'should return the result if the query matches views' do
      query = 'my query'
      result = [{a: :b}]

      expect(dummy).to receive(:query).with(query).and_return(result)

      expect(dummy.view_exists?(query)).to eq(result)
    end
  end

  describe '#views_exist?' do
    it 'should execute the given query' do
      query = 'my query'

      expect(dummy).to receive(:query).with(query).and_return([{}])

      dummy.views_exist?(query)
    end

    it 'should execute the given queries' do
      query = ['my query', 'my query 2']

      expect(dummy).to receive(:query).with(query[0]).and_return([{value: 1}])
      expect(dummy).to receive(:query).with(query[1]).and_return([{value: 2}])

      dummy.views_exist?(query)
    end

    it 'should return false if not all queries match a view' do
      query = ['my query', 'my query 2']

      expect(dummy).to receive(:query).with(query[0]).and_return([{value: 1}])
      expect(dummy).to receive(:query).with(query[1]).and_return([])

      expect(dummy.views_exist?(query)).to eq(false)
    end

    it 'should return the result if all queries match views' do
      query = ['my query', 'my query 2']
      result = [[{value: 1}], [{value: 2}]]

      expect(dummy).to receive(:query).with(query[0]).and_return([{value: 1}])
      expect(dummy).to receive(:query).with(query[1]).and_return([{value: 2}])

      expect(dummy.views_exist?(query)).to eq(result)
    end
  end

  describe '#expect_view' do
    it 'should fail if no views are matched' do
      query = 'my query'

      expect(dummy).to receive(:view_exists?).with(query).and_return(false)

      expect{dummy.expect_view(query)}.to raise_error(Calabash::Wait::ViewNotFoundError,
                                                      "No view matched #{dummy.parse_query_list(query)}")
    end

    it 'should not fail if views are matched' do
      query = 'my query'

      expect(dummy).to receive(:view_exists?).with(query).and_return([{}])

      expect{dummy.expect_view(query)}.not_to raise_error
    end
  end

  describe '#expect_views' do
    it 'should fail if no views are matched' do
      query = 'my query'

      expect(dummy).to receive(:views_exist?).with([query]).and_return(false)

      expect{dummy.expect_views(query)}.to raise_error(Calabash::Wait::ViewNotFoundError,
                                                       "Not all queries #{dummy.parse_query_list(query)} matched a view")
    end


    it 'should fail if not all queries match a view' do
      query = ['my query', 'my query 2']

      expect(dummy).to receive(:views_exist?).with(query).and_return(false)

      expect{dummy.expect_views(query)}.to raise_error(Calabash::Wait::ViewNotFoundError,
                                                      "Not all queries #{dummy.parse_query_list(query)} matched a view")
    end

    it 'should not fail a view is matched' do
      query = 'my query'

      expect(dummy).to receive(:views_exist?).with([query]).and_return([{}])

      expect{dummy.expect_views(query)}.not_to raise_error
    end

    it 'should not fail if views are matched' do
      query = ['my query', 'my query 2']

      expect(dummy).to receive(:views_exist?).with(query).and_return([[{}], [{}]])

      expect{dummy.expect_views(query)}.not_to raise_error
    end
  end

  describe '#do_not_expect_view' do
    it 'should not fail if no views are matched' do
      query = 'my query'

      expect(dummy).to receive(:view_exists?).with(query).and_return(false)

      expect{dummy.do_not_expect_view(query)}.not_to raise_error
    end

    it 'should fail if views are matched' do
      query = 'my query'

      expect(dummy).to receive(:view_exists?).with(query).and_return([{}])

      expect{dummy.do_not_expect_view(query)}.to raise_error(Calabash::Wait::ViewFoundError,
                                                      "A view matched #{dummy.parse_query_list(query)}")
    end
  end

  describe '#do_not_expect_views' do
    it 'should not fail if no views are matched' do
      query = 'my query'

      expect(dummy).to receive(:view_exists?).with(query).and_return(false)

      expect{dummy.do_not_expect_views(query)}.not_to raise_error
    end


    it 'should not fail if no queries match a view' do
      query = ['my query', 'my query 2']

      expect(dummy).to receive(:view_exists?).with(query[0]).and_return(false)
      expect(dummy).to receive(:view_exists?).with(query[1]).and_return(false)

      expect{dummy.do_not_expect_views(query)}.not_to raise_error
    end

    it 'should fail if a view is matched' do
      query = 'my query'

      expect(dummy).to receive(:view_exists?).with(query).and_return([{}])

      expect{dummy.do_not_expect_views(query)}.to raise_error(Calabash::Wait::ViewFoundError,
                                                       "Some views matched #{dummy.parse_query_list(query)}")
    end

    it 'should fail if some views are matched' do
      query = ['my query', 'my query 2']

      expect(dummy).to receive(:view_exists?).with(query[0]).and_return([{}])
      expect(dummy).to receive(:view_exists?).with(query[1]).and_return([{}])

      expect{dummy.do_not_expect_views(query)}.to raise_error(Calabash::Wait::ViewFoundError,
                                                              "Some views matched #{dummy.parse_query_list(query)}")

      expect(dummy).to receive(:view_exists?).with(query[0]).and_return(false)
      expect(dummy).to receive(:view_exists?).with(query[1]).and_return([{}])

      expect{dummy.do_not_expect_views(query)}.to raise_error(Calabash::Wait::ViewFoundError,
                                                              "Some views matched #{dummy.parse_query_list(query)}")
    end
  end

  describe '#view_should_exist' do
    it 'should be an alias of #expect_view' do
      expect(dummy.method(:view_should_exist)).to eq(dummy.method(:expect_view))
    end
  end

  describe '#views_should_exist' do
    it 'should be an alias of #expect_views' do
      expect(dummy.method(:views_should_exist)).to eq(dummy.method(:expect_views))
    end
  end

  describe '#view_should_not_exist' do
    it 'should be an alias of #do_not_expect_view' do
      expect(dummy.method(:view_should_not_exist)).to eq(dummy.method(:do_not_expect_view))
    end
  end

  describe '#views_should_not_exist' do
    it 'should be an alias of #do_not_expect_views' do
      expect(dummy.method(:views_should_not_exist)).to eq(dummy.method(:do_not_expect_views))
    end
  end

  describe '#wait_for_view' do
    it 'should wait for the view to appear' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      returned = [false, false, false, false, false, false, false, false, false, [{}]]

      expect(dummy).to receive(:view_exists?).with(query).exactly(10).times.and_return(*returned)
      expect(dummy).to receive(:sleep).with(Calabash::Wait.default_options[:retry_frequency]).exactly(9).times

      dummy.wait_for_view(query)
    end

    it 'should fail if the view does not appear' do
      stub_const('Calabash::Wait::Timeout', AlwaysRaiseTimeout)
      query = 'my query'

      allow(dummy).to receive(:view_exists?).with(query).and_return(false)
      expect(dummy).to receive(:fail).with(Calabash::Wait::ViewNotFoundError, "Waited 30 seconds for #{dummy.parse_query_list(query)} to match a view").and_call_original

      expect{dummy.wait_for_view(query)}.to raise_error
    end

    it 'should use defaults' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      default_options = Calabash::Wait.default_options

      expect(dummy).not_to receive(:sleep)
      expect(dummy).to receive(:view_exists?).with(query).and_return([{}])
      expect(dummy).to receive(:wait_for).with(anything,
                                               {timeout: default_options[:timeout],
                                                exception_class: Calabash::Wait::ViewNotFoundError,
                                                retry_frequency: default_options[:retry_frequency]}).and_call_original

      dummy.wait_for_view(query)
    end

    it 'should allow options' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      timeout = 10
      message = 'my message'
      retry_frequency = 5
      exception_class = Class.new(RuntimeError)

      expect(dummy).not_to receive(:sleep)
      expect(dummy).to receive(:view_exists?).with(query).and_return([{}])
      expect(dummy).to receive(:wait_for).with(message,
                                               {timeout: timeout,
                                                exception_class: exception_class,
                                                retry_frequency: retry_frequency}).and_call_original

      dummy.wait_for_view(query, timeout: timeout, message: message,
                          retry_frequency: retry_frequency, exception_class: exception_class)
    end

    it 'should return the first element' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      result = {value: :value}

      expect(dummy).to receive(:view_exists?).with(query).and_return([result])

      expect(dummy.wait_for_view(query)).to eq(result)
    end
  end

  describe '#wait_for_views' do
    it 'should wait for the view to appear' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      returned = [false, false, false, false, false, false, false, false, false, [{}]]

      expect(dummy).to receive(:views_exist?).with([query]).exactly(10).times.and_return(*returned)
      expect(dummy).to receive(:sleep).with(Calabash::Wait.default_options[:retry_frequency]).exactly(9).times

      dummy.wait_for_views(query)
    end

    it 'should wait for the views to appear' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = ['my query 1', 'my query 2']
      returned = [false, false, false, false, false, false, false, false, false, [[{}]]]

      expect(dummy).to receive(:views_exist?).with(query).exactly(10).times.and_return(*returned)
      expect(dummy).to receive(:sleep).with(Calabash::Wait.default_options[:retry_frequency]).exactly(9).times

      dummy.wait_for_views(query)
    end

    it 'should fail if the view does not appear' do
      stub_const('Calabash::Wait::Timeout', AlwaysRaiseTimeout)
      query = 'my query'

      allow(dummy).to receive(:views_exist?).with([query]).and_return(false)
      expect(dummy).to receive(:fail).with(Calabash::Wait::ViewNotFoundError,
                                           "Waited 30 seconds for #{dummy.parse_query_list(query)} to each match a view")
                           .and_call_original

      expect{dummy.wait_for_views(query)}.to raise_error
    end

    it 'should fail if the views do not appear' do
      stub_const('Calabash::Wait::Timeout', AlwaysRaiseTimeout)
      query = ['my query 1', 'my query 2']

      allow(dummy).to receive(:views_exist?).with(query).and_return(false)
      expect(dummy).to receive(:fail).with(Calabash::Wait::ViewNotFoundError,
                                           "Waited 30 seconds for #{dummy.parse_query_list(query)} to each match a view")
                           .and_call_original

      expect{dummy.wait_for_views(query)}.to raise_error
    end

    it 'should use defaults' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      default_options = Calabash::Wait.default_options

      expect(dummy).not_to receive(:sleep)
      expect(dummy).to receive(:views_exist?).with([query]).and_return([[{}]])
      expect(dummy).to receive(:wait_for).with(anything,
                                               {timeout: default_options[:timeout],
                                                exception_class: Calabash::Wait::ViewNotFoundError,
                                                retry_frequency: default_options[:retry_frequency]}).and_call_original

      dummy.wait_for_views(query)
    end

    it 'should allow options' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      timeout = 10
      message = 'my message'
      retry_frequency = 5
      exception_class = Class.new(RuntimeError)

      expect(dummy).not_to receive(:sleep)
      expect(dummy).to receive(:views_exist?).with([query]).and_return([[{}]])
      expect(dummy).to receive(:wait_for).with(message,
                                               {timeout: timeout,
                                                exception_class: exception_class,
                                                retry_frequency: retry_frequency}).and_call_original

      dummy.wait_for_views(query, timeout: timeout, message: message,
                          retry_frequency: retry_frequency, exception_class: exception_class)
    end
  end

  describe '#wait_for_no_view' do
    it 'should wait for the view to disappear' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      returned = [[{}], [{}], [{}], [{}], [{}], [{}], [{}], [{}], [{}], false]

      expect(dummy).to receive(:view_exists?).with(query).exactly(10).times.and_return(*returned)
      expect(dummy).to receive(:sleep).with(Calabash::Wait.default_options[:retry_frequency]).exactly(9).times

      dummy.wait_for_no_view(query)
    end

    it 'should fail if the view does not disappear' do
      stub_const('Calabash::Wait::Timeout', AlwaysRaiseTimeout)
      query = 'my query'

      allow(dummy).to receive(:view_exists?).with(query).and_return([{}])
      expect(dummy).to receive(:fail).with(Calabash::Wait::ViewFoundError,
                                           "Waited 30 seconds for #{dummy.parse_query_list(query)} to not match any view")
                           .and_call_original

      expect{dummy.wait_for_no_view(query)}.to raise_error
    end

    it 'should use defaults' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      default_options = Calabash::Wait.default_options

      expect(dummy).not_to receive(:sleep)
      expect(dummy).to receive(:view_exists?).with(query).and_return(false)
      expect(dummy).to receive(:wait_for).with(anything,
                                               {timeout: default_options[:timeout],
                                                exception_class: Calabash::Wait::ViewFoundError,
                                                retry_frequency: default_options[:retry_frequency]}).and_call_original

      dummy.wait_for_no_view(query)
    end

    it 'should allow options' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      timeout = 10
      message = 'my message'
      retry_frequency = 5
      exception_class = Class.new(RuntimeError)

      expect(dummy).not_to receive(:sleep)
      expect(dummy).to receive(:view_exists?).with(query).and_return(false)
      expect(dummy).to receive(:wait_for).with(message,
                                               {timeout: timeout,
                                                exception_class: exception_class,
                                                retry_frequency: retry_frequency}).and_call_original

      dummy.wait_for_no_view(query, timeout: timeout, message: message,
                          retry_frequency: retry_frequency, exception_class: exception_class)
    end
  end

  describe '#wait_for_no_views' do
    it 'should wait for the view to disappear' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      returned = [[{}], [{}], [{}], [{}], [{}], [{}], [{}], [{}], [{}], false]

      expect(dummy).to receive(:views_exist?).with([query]).exactly(10).times.and_return(*returned)
      expect(dummy).to receive(:sleep).with(Calabash::Wait.default_options[:retry_frequency]).exactly(9).times

      dummy.wait_for_no_views(query)
    end

    it 'should wait for the views to disappear' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = ['my query 1', 'my query 2']
      returned = [[{}], [{}], [{}], [{}], [{}], [{}], [{}], [{}], [{}], false]

      expect(dummy).to receive(:views_exist?).with(query).exactly(10).times.and_return(*returned)
      expect(dummy).to receive(:sleep).with(Calabash::Wait.default_options[:retry_frequency]).exactly(9).times

      dummy.wait_for_no_views(query)
    end

    it 'should fail if the view does not disappear' do
      stub_const('Calabash::Wait::Timeout', AlwaysRaiseTimeout)
      query = 'my query'

      allow(dummy).to receive(:views_exist?).with([query]).and_return([{}])
      expect(dummy).to receive(:fail).with(Calabash::Wait::ViewFoundError,
                                           "Waited 30 seconds for #{dummy.parse_query_list(query)} to each not match any view")
                           .and_call_original

      expect{dummy.wait_for_no_views(query)}.to raise_error
    end

    it 'should fail if the views do not disappear' do
      stub_const('Calabash::Wait::Timeout', AlwaysRaiseTimeout)
      query = ['my query 1', 'my query 2']

      allow(dummy).to receive(:views_exist?).with(query).and_return([{}])
      expect(dummy).to receive(:fail).with(Calabash::Wait::ViewFoundError,
                                           "Waited 30 seconds for #{dummy.parse_query_list(query)} to each not match any view")
                           .and_call_original

      expect{dummy.wait_for_no_views(query)}.to raise_error
    end

    it 'should use defaults' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      default_options = Calabash::Wait.default_options

      expect(dummy).not_to receive(:sleep)
      expect(dummy).to receive(:views_exist?).with([query]).and_return(false)
      expect(dummy).to receive(:wait_for).with(anything,
                                               {timeout: default_options[:timeout],
                                                exception_class: Calabash::Wait::ViewFoundError,
                                                retry_frequency: default_options[:retry_frequency]}).and_call_original

      dummy.wait_for_no_views(query)
    end

    it 'should allow options' do
      stub_const('Calabash::Wait::Timeout', NeverRaiseTimeout)
      query = 'my query'
      timeout = 10
      message = 'my message'
      retry_frequency = 5
      exception_class = Class.new(RuntimeError)

      expect(dummy).not_to receive(:sleep)
      expect(dummy).to receive(:views_exist?).with([query]).and_return(false)
      expect(dummy).to receive(:wait_for).with(message,
                                               {timeout: timeout,
                                                exception_class: exception_class,
                                                retry_frequency: retry_frequency}).and_call_original

      dummy.wait_for_no_views(query, timeout: timeout, message: message,
                           retry_frequency: retry_frequency, exception_class: exception_class)
    end
  end

  describe Calabash::Wait::TimeoutError do
    it 'should inherit from RuntimeError' do
      expect(Calabash::Wait::TimeoutError.ancestors).to include(RuntimeError)
    end
  end

  describe Calabash::Wait::UnexpectedMatchError do
    it 'should inherit from RuntimeError' do
      expect(Calabash::Wait::UnexpectedMatchError.ancestors).to include(RuntimeError)
    end
  end

  describe Calabash::Wait::ViewFoundError do
    it 'should inherit from UnexpectedMatchError' do
      expect(Calabash::Wait::ViewFoundError.ancestors).to include(Calabash::Wait::UnexpectedMatchError)
    end
  end

  describe Calabash::Wait::ViewNotFoundError do
    it 'should inherit from UnexpectedMatchError' do
      expect(Calabash::Wait::ViewNotFoundError.ancestors).to include(Calabash::Wait::UnexpectedMatchError)
    end
  end
end
