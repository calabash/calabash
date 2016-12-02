describe Calabash do
  let(:dummy) {Class.new {include Calabash}}
  let(:dummy_instance) {dummy.new}

  let(:device) do
    Class.new do
      def start_app(_, _); ; end
      def stop_app; ; end
      def install_app(_); ; end
      def ensure_app_installed(_); ; end
      def uninstall_app(_); ; end
      def clear_app_data(_); ; end
    end.new
  end

  describe 'when asked to embed' do
    before do
      # Reset EmbeddingContext
      calabash_file = File.join(File.dirname(__FILE__), '..', '..', 'lib', 'calabash.rb')
      load calabash_file
    end

    it 'should by default warn that embed is impossible' do
      expect(Calabash::Logger).to receive(:warn)
                                      .with('Embed is not available in this context. Will not embed.')

      dummy_instance.embed('a', 'b', 'c')
    end

    it 'should invoke Cucumber\'s embed method when running in context of Cucumber' do
      name = 'my_name'

      module Cucumber
        module RbSupport
          module RbWorld
            def embed(name, *_)
              "MY RESULT #{name}"
            end
          end
        end
      end

      Class.new do
        class << self
          include Cucumber::RbSupport::RbWorld
        end

        extend Calabash

        include Calabash
      end

      expect(dummy_instance.embed(name)).to eq("MY RESULT #{name}")
    end

    it 'should not have embed defined as an instance method' do
      expect(Calabash.instance_methods).not_to include(:embed)
    end
  end
end
