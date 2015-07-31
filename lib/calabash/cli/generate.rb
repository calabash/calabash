require 'fileutils'

module Calabash
  # @!visibility private
  module CLI
    # @!visibility private
    module Generate
      def parse_generate_arguments!
        if File.exist?('features')
          puts "A features directory already exists. Please remove this to continue."
          exit 1
        end

        if File.exist?('config')
          puts "A config directory already exists. Please remove this to continue."
          exit 1
        end

        reset_between = :features
        reset_method = :clear

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

        gemfile = File.read(file(File.join('Gemfile')))

        unless File.exist?('Gemfile')
          File.open('Gemfile', 'w') {|file| file.write(gemfile) }
        end

        gitignore = File.read(file(File.join('.gitignore')))

        unless File.exist?('.gitignore')
          File.open('.gitignore', 'w') {|file| file.write(gitignore) }
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
