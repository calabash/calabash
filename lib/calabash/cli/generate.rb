require 'fileutils'

module Calabash
  module CLI
    module Generate
      def parse_generate_arguments!
        type = @arguments.shift

        if type.nil?
          msg("Question") do
            puts "Calabash is about to create a subdirectory called features and config,"
            puts "features will contain all your calabash tests."
            puts "Please hit return to confirm that's what you want."
          end

          unless STDIN.gets.chomp == ''
            exit 2
          end

          if File.exist?('features')
            puts "A features directory already exists. Please remove this to continue."
            exit 1
          end

          if File.exist?('config')
            puts "A config directory already exists. Please remove this to continue."
            exit 1
          end

          reset_between = nil
          reset_method = nil

          puts "Do you want to reset the app by default? ((n)ever/between (s)cenarios/between (f)eatures) "
          input = STDIN.gets.chomp.downcase

          case input
            when 'n'
              reset_between = :never
            when 's'
              reset_between = :scenarios
            when 'f'
              reset_between = :features
            else
              puts "Invalid input '#{input}'"
              exit(3)
          end

          unless reset_between == :never
            puts "How would you like to reset the app by default? ((c)learing/(r)einstalling) "
            input = STDIN.gets.chomp.downcase

            case input
              when 'c'
                reset_method = :clear
              when 'r'
                reset_method = :reinstall
              else
                puts "Invalid input '#{input}'"
                exit(4)
            end
          end

          cucumber_config = File.read(file(File.join('config', 'cucumber.yml')))

          env = File.read(file(File.join('features', 'support', 'env.rb')))
          sample_feature = File.read(file(File.join('features', 'sample.feature')))
          calabash_steps = File.read(file(File.join('features', 'step_definitions', 'calabash_steps.rb')))

          hooks = File.read(file(File.join('features', 'support', 'hooks.rb')))
          hooks.sub!("#!DEFAULT_RESET_BETWEEN#!", ":#{reset_between}")

          if reset_method.nil?
            hooks.sub!("#!DEFAULT_RESET_METHOD#!", 'nil')
          else
            hooks.sub!("#!DEFAULT_RESET_METHOD#!", ":#{reset_method}")
          end

          FileUtils.mkdir('config')

          File.open(File.join('config', 'cucumber.yml'), 'w') {|file| file.write(cucumber_config) }

          FileUtils.mkdir('features')
          FileUtils.mkdir('features/step_definitions')
          FileUtils.mkdir('features/support')

          File.open(File.join('features', 'sample.feature'), 'w') {|file| file.write(sample_feature) }
          File.open(File.join('features', 'step_definitions', 'calabash_steps.rb'), 'w') {|file| file.write(calabash_steps) }
          File.open(File.join('features', 'support', 'hooks.rb'), 'w') {|file| file.write(hooks) }
          File.open(File.join('features', 'support', 'env.rb'), 'w') {|file| file.write(env) }
        else
          fail("Invalid argument #{type}", :gen)
        end
      end

      def file(file)
        File.join(Calabash::Environment::SKELETON_DIR_PATH, file)
      end

      def msg(title, &block)
        puts "\n" + "-"*10 + title + "-"*10
        block.call
        puts "-"*10 + "-------" + "-"*10 + "\n"
      end


    end
  end
end
